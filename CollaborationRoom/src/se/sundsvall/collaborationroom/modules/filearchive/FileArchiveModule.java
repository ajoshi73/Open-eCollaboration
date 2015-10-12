package se.sundsvall.collaborationroom.modules.filearchive;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadBase.FileSizeLimitExceededException;
import org.apache.commons.fileupload.FileUploadBase.SizeLimitExceededException;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.io.FilenameUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.enums.EventFormat;
import se.dosf.communitybase.events.CBSearchableItemAddEvent;
import se.dosf.communitybase.events.CBSearchableItemDeleteEvent;
import se.dosf.communitybase.events.CBSearchableItemUpdateEvent;
import se.dosf.communitybase.interfaces.CBSearchable;
import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.dosf.communitybase.interfaces.EventTransformer;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.interfaces.SectionEventProvider;
import se.dosf.communitybase.interfaces.StorageUsage;
import se.dosf.communitybase.interfaces.TagCache;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.search.SearchModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.filearchive.beans.Category;
import se.sundsvall.collaborationroom.modules.filearchive.beans.File;
import se.sundsvall.collaborationroom.modules.filearchive.beans.FileFilter;
import se.sundsvall.collaborationroom.modules.filearchive.beans.FilePostedBeanElementableListener;
import se.sundsvall.collaborationroom.modules.filearchive.beans.FileSearchableItem;
import se.sundsvall.collaborationroom.modules.filearchive.cruds.CategoryCRUD;
import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.sundsvall.collaborationroom.modules.utils.comparators.PostedComparator;
import se.sundsvall.collaborationroom.modules.utils.comparators.UpdatedComparator;
import se.unlogic.fileuploadutils.MultipartRequest;
import se.unlogic.hierarchy.core.annotations.HTMLEditorSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextAreaSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.annotations.XSLVariable;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.crud.TransactionRequestFilter;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryParameter;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.dao.TransactionHandler;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.image.ImageUtils;
import se.unlogic.standardutils.io.BinarySizes;
import se.unlogic.standardutils.io.FileUtils;
import se.unlogic.standardutils.json.JsonArray;
import se.unlogic.standardutils.json.JsonUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.populators.IntegerPopulator;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.MillisecondTimeUnits;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.standardutils.xml.XMLGeneratorDocument;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.fileicons.FileIconHandler;
import se.unlogic.webutils.http.HTTPUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.http.enums.ContentDisposition;
import se.unlogic.webutils.validation.ValidationUtils;

public class FileArchiveModule extends CBBaseModule implements CBSearchable, SectionEventProvider, EventTransformer<File>, ShortCutProvider, StorageUsage {

	private static final List<String> DEFAULT_ALLOWED_FILE_EXTENSIONS = CollectionUtils.getList("doc", "docx", "xls", "xlsx", "txt", "odt", "odf", "pdf", "png", "jpg", "gif");

	private static final PostedComparator POSTED_COMPARATOR = new PostedComparator();
	private static final UpdatedComparator UPDATED_COMPARATOR = new UpdatedComparator();

	public static final String FILE_POSTED_EVENT_TYPE = "posted";
	public static final String FILE_UPDATED_EVENT_TYPE = "updated";

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Tag hit count", description = "The number of tags to get from tag cache during auto complete queries")
	private Integer tagHitCount = 30;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Base file store", description = "Directory where section filearchive directory is created", required = true)
	protected String baseFilestore;

	@ModuleSetting(allowsNull = true)
	@TextFieldSettingDescriptor(name = "Temp dir", description = "Directory for temporary files. Should be on the same filesystem as the file store for best performance. If not set system default temp directory will be used")
	protected String tempDir;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "File lock time (in hours)", description = "The number of hours files should be locked", required = true, formatValidator = PositiveStringIntegerValidator.class)
	protected Integer fileLockTime = 4;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Max file size", description = "Maxmium file size in megabytes allowed", required = true, formatValidator = PositiveStringIntegerValidator.class)
	protected Integer maxFileSize = 15;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Max upload sizee", description = "Maxmium upload size in megabytes allowed in a single post request", required = true, formatValidator = PositiveStringIntegerValidator.class)
	protected Integer diskThreshold = 100;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "RAM threshold", description = "Maximum size of files in KB to be buffered in RAM during file uploads. Files exceeding the threshold are written to disk instead.", required = true, formatValidator = PositiveStringIntegerValidator.class)
	protected Integer ramThreshold = 500;

	@ModuleSetting(id = "extensions")
	@TextAreaSettingDescriptor(id = "extensions", name = "Allowed File Types", description = "Controls which filetypes are to be allowed (put each file extension on a new line ex. \"doc\")", required = false)
	protected List<String> allowedFileExtensions = DEFAULT_ALLOWED_FILE_EXTENSIONS;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Event stylesheet", description = "The stylesheet used to transform events")
	private String eventStylesheet = "FileEvent.sv.xsl";
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Email attachement domain", description = "The email domain used to send email attachements to")
	private String emailDomain;
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Email User-agent regex", description = "User-agent regex that needs to match to replace normal upload with email attachement upload")
	private String emailUserAgentRegex = ".*(iPad|iPhone|iPod).*";
	
	@ModuleSetting
	@HTMLEditorSettingDescriptor(name = "Email help text", description = "%EmailAddress by the email address the user should send to. %Category is replaced by the selected category.")
	private String emailHelpText = "";

	@XSLVariable(prefix = "java.")
	private String shortCutText = "Upload file";

	@XSLVariable(prefix = "java.")
	private String autoCreatedCategoryName = "Other files";
	
	@InstanceManagerDependency(required = true)
	protected TagCache tagCache;

	@InstanceManagerDependency(required = false)
	protected SearchModule searchModule;

	@InstanceManagerDependency(required = false)
	protected UserProfileProvider userProfileProvider;

	private FileFilter fileFilter;

	private AdvancedAnnotatedDAOWrapper<Category, Integer> categoryDAO;

	private AnnotatedDAO<File> fileDAO;

	private CategoryCRUD categoryCRUD;

	private QueryParameter<Category, Integer> sectionIDParameter;

	private QueryParameterFactory<File, Integer> fileIDParamFactory;

	private ConcurrentHashMap<Integer, Category> categoryCacheMap;

	private CopyOnWriteArrayList<Category> categoryCacheList;

	private SimpleViewFragmentTransformer eventFragmentTransformer;

	@Override
	protected void moduleConfigured() throws Exception {

		super.moduleConfigured();

		fileFilter = new FileFilter(allowedFileExtensions);

		if (baseFilestore != null) {

			java.io.File file = new java.io.File(getSectionFilestore());

			if (!file.isDirectory()) {

				if (!file.mkdir()) {

					log.error("Unable to create filestore folder for module " + moduleDescriptor);
				}
			}

		} else {

			log.warn("Module " + this.moduleDescriptor + " is not properly configured, please check modulesettings");
		}

		if (eventStylesheet == null) {

			log.warn("No stylesheet set for event transformations");
			eventFragmentTransformer = null;

		} else {

			try {
				eventFragmentTransformer = new SimpleViewFragmentTransformer(eventStylesheet, systemInterface.getEncoding(), this.getClass(), moduleDescriptor, sectionInterface);

			} catch (Exception e) {

				log.error("Error parsing stylesheet for event transformations", e);
				eventFragmentTransformer = null;
			}
		}
		
		if(!StringUtils.isEmpty(emailUserAgentRegex)){
			try{
				Pattern.compile(emailUserAgentRegex);
			} catch(PatternSyntaxException e){
				log.warn("emailUserAgentRegex invalid", e);
			}
		}
	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, FileArchiveModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		fileDAO = daoFactory.getDAO(File.class);
		fileIDParamFactory = fileDAO.getParamFactory("fileID", Integer.class);

		categoryDAO = daoFactory.getDAO(Category.class).getAdvancedWrapper(Integer.class);

		sectionIDParameter = categoryDAO.getAnnotatedDAO().getParamFactory("sectionID", Integer.class).getParameter(getSectionID());

		categoryDAO.getGetQuery().addParameter(sectionIDParameter);
		categoryDAO.getGetAllQuery().addParameter(sectionIDParameter);

		categoryCRUD = new CategoryCRUD(categoryDAO, this);
		categoryCRUD.addRequestFilter(new TransactionRequestFilter(dataSource));

		cacheCategories();

	}

	protected void cacheCategories() throws SQLException {

		HighLevelQuery<Category> query = new HighLevelQuery<Category>(Category.FILES_RELATION);
		query.addParameter(sectionIDParameter);

		List<Category> categories = categoryDAO.getAnnotatedDAO().getAll(query);

		if (categories == null) {

			this.categoryCacheList = new CopyOnWriteArrayList<Category>();
			this.categoryCacheMap = new ConcurrentHashMap<Integer, Category>();

		} else {

			ConcurrentHashMap<Integer, Category> categoryMap = new ConcurrentHashMap<Integer, Category>();

			for (Category category : categories) {

				if (category.getFiles() != null) {

					Collections.sort(category.getFiles());
				}

				categoryMap.put(category.getCategoryID(), category);

			}

			Collections.sort(categories);

			this.categoryCacheList = new CopyOnWriteArrayList<Category>(categories);
			this.categoryCacheMap = categoryMap;
		}
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return defaultMethod(req, res, user, uriParser, null);

	}

	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		checkCategories();
		
		Document doc = this.createDocument(req, uriParser, user);
		
		// iOS workaround
		if(!StringUtils.isEmpty(emailDomain) && !StringUtils.isEmpty(emailUserAgentRegex) && !StringUtils.isEmpty(emailHelpText)){
			String userAgent = req.getHeader("User-Agent");
			
			try{
				if(Pattern.matches(emailUserAgentRegex, userAgent)){
					log.info("Detected apple device, using email attachment instead of http file upload");
					XMLUtils.appendNewElement(doc, (Element) doc.getFirstChild(), "EmailDomain", emailDomain);
					XMLUtils.appendNewElement(doc, (Element) doc.getFirstChild(), "EmailHelpText", emailHelpText);
				}
				
			}catch (PatternSyntaxException e){
				log.warn("emailUserAgentRegex invalid", e);
			}
		}

		if (fileFilter.getAllowedFileTypes() != null) {
			XMLUtils.appendNewCDATAElement(doc, doc.getDocumentElement(), "allowedFileTypes", StringUtils.toQuotedCommaSeparatedString(fileFilter.getAllowedFileTypes()));
		}

		Element listElement = XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ListCategories");

		FilePostedBeanElementableListener elementableListener = new FilePostedBeanElementableListener(systemInterface.getDefaultLanguage().getLanguageCode(), user, null);

		XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

		generatorDocument.addElementableListener(File.class, elementableListener);

		XMLUtils.append(generatorDocument, listElement, categoryCacheList);

		if (validationErrors != null) {
			XMLUtils.append(doc, listElement, validationErrors);
			listElement.appendChild(RequestUtils.getRequestParameters(req, doc));
		}

		return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addCategory(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return categoryCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateCategory(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return categoryCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteCategory(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return categoryCRUD.delete(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse attachFiles(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		String redirectURI = req.getParameter("redirectURI");

		if (redirectURI != null) {
			
			checkCategories();
			
			Document doc = this.createDocument(req, uriParser, user);

			if (fileFilter.getAllowedFileTypes() != null) {
				XMLUtils.appendNewCDATAElement(doc, doc.getDocumentElement(), "allowedFileTypes", StringUtils.toQuotedCommaSeparatedString(fileFilter.getAllowedFileTypes()));
			}

			Element attachFilesElement = XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "AttachFiles");

			FilePostedBeanElementableListener elementableListener = new FilePostedBeanElementableListener(systemInterface.getDefaultLanguage().getLanguageCode(), user, null);

			XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

			generatorDocument.addElementableListener(File.class, elementableListener);

			XMLUtils.append(generatorDocument, attachFilesElement, categoryCacheList);

			XMLUtils.appendNewElement(generatorDocument, attachFilesElement, "redirectURI", redirectURI);

			attachFilesElement.appendChild(RequestUtils.getRequestParameters(req, generatorDocument));

			return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());

		}

		throw new URINotFoundException(uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse ajaxUploadFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		Integer categoryID = uriParser.getInt(2);

		Category category = null;

		if (req.getMethod().equalsIgnoreCase("POST") && categoryID != null && (category = getCachedCategory(categoryID)) != null) {

			MultipartRequest requestWrapper = null;

			TransactionHandler transactionHandler = null;

			try {

				requestWrapper = new MultipartRequest(this.ramThreshold * BinarySizes.KiloByte, this.diskThreshold * BinarySizes.MegaByte, this.maxFileSize * BinarySizes.MegaByte, req);

				if (requestWrapper.getFileCount() == 0) {

					return sendFileUploadError(req, res, uriParser, user, new ValidationError("NoAttachedFile"));
				}

				FileItem fileItem = requestWrapper.getFiles().get(0);

				if (fileFilter.accept(fileItem)) {

					transactionHandler = categoryDAO.createTransaction();

					Timestamp timestamp = TimeUtils.getCurrentTimestamp();

					File file = new File();
					file.setFilename(FileUtils.toValidHttpFilename(StringUtils.parseUTF8(FilenameUtils.getName(fileItem.getName()))));
					file.setSize(fileItem.getSize());
					file.setPosted(timestamp);
					file.setPoster(user);
					file.setCategory(category);
					file.setTags(populateTags(requestWrapper, user, uriParser, true));

					fileDAO.add(file, transactionHandler, null);

					try {

						java.io.File fileSystemFile = new java.io.File(getFilePath(file));

						fileItem.write(fileSystemFile);

					} catch (Exception e) {

						transactionHandler.abort();

						log.error("Error adding file " + fileItem.getName() + " to category " + category + " uploaded by user " + user);

						return sendFileUploadError(req, res, uriParser, user, new ValidationError("UnableToUploadFile"));
					}

					transactionHandler.commit();

					log.info("User " + user + " uploaded file " + file + " to category " + category + " in section room " + getSectionID());

					cacheCategory(categoryID);

					if (file.getTags() != null) {

						tagCache.addTags(file.getTags());
					}

					systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemAddEvent(new FileSearchableItem(file, category, "/" + moduleDescriptor.getAlias() + "/#file" + file.getFileID(), new java.io.File(getFilePath(file))), moduleDescriptor), EventTarget.ALL);

					if (sectionEventHandler != null && eventFragmentTransformer != null) {

						sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getPostedEvent(file));
					}

					Document doc = createDocument(requestWrapper, uriParser, user);

					Element uploadedFileElement = XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "UploadedFile");

					Element fileElement = file.toXML(doc);

					appendFormattedDates(file, doc, fileElement);

					uploadedFileElement.appendChild(fileElement);

					SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);
					moduleResponse.excludeSystemTransformation(true);

					return moduleResponse;

				} else {

					log.info("Invalid file type for file " + fileItem.getName() + " uploaded by user " + user);

					return sendFileUploadError(req, res, uriParser, user, new ValidationError("InvalidFileType"));

				}

			} catch (FileSizeLimitExceededException e) {

				return sendFileUploadError(req, res, uriParser, user, new ValidationError("FileSizeToBig"));

			} catch (SizeLimitExceededException e) {

				return sendFileUploadError(req, res, uriParser, user, new ValidationError("FileSizeToBig"));

			} catch (FileUploadException e) {

				return sendFileUploadError(req, res, uriParser, user, new ValidationError("UnableToParseRequest"));
				
			} finally {

				if (requestWrapper != null) {
					requestWrapper.deleteFiles();
				}

				TransactionHandler.autoClose(transactionHandler);

			}

		}

		throw new URINotFoundException(uriParser);
	}
	
	private ForegroundModuleResponse sendFileUploadError(HttpServletRequest req, HttpServletResponse res, URIParser uriParser, User user, ValidationError error) {
		
		Document doc = createDocument(req, uriParser, user);

		Element element = XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "FileUploadError");
		
		element.appendChild(error.toXML(doc));
		
		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);
		moduleResponse.excludeSystemTransformation(true);

		return moduleResponse;
		
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		File file = getRequestedFile(req, uriParser);

		if (file == null) {

			throw new URINotFoundException(uriParser);
		}

		checkLockAccess(user, file);

		List<ValidationError> errors = new ArrayList<ValidationError>();

		Integer categoryID = ValidationUtils.validateParameter("categoryID", req, true, IntegerPopulator.getPopulator(), errors);

		Category category = null;

		if (categoryID != null) {

			category = getCachedCategory(categoryID);

			if (category == null) {

				errors.add(new ValidationError("CategoryNotFound"));
			}

		}

		if (!errors.isEmpty()) {

			return defaultMethod(req, res, user, uriParser, errors);
		}

		file.setTags(populateTags(req, user, uriParser, false));
		file.setUpdated(TimeUtils.getCurrentTimestamp());
		file.setEditor(user);

		Category currentCategory = file.getCategory();

		if (!currentCategory.equals(category)) {

			file.setCategory(category);

			fileDAO.update(file);

			cacheCategory(category.getCategoryID());

		} else {

			fileDAO.update(file);

		}

		cacheCategory(currentCategory.getCategoryID());

		if (file.getTags() != null) {

			tagCache.addTags(file.getTags());
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemUpdateEvent(new FileSearchableItem(file, category, "/" + moduleDescriptor.getAlias() + "/#file" + file.getFileID(), new java.io.File(getFilePath(file))), moduleDescriptor), EventTarget.ALL);

		if (sectionEventHandler != null && eventFragmentTransformer != null) {

			sectionEventHandler.replaceEvent(moduleDescriptor.getSectionID(), getUpdatedEvent(file));
		}

		redirectToDefaultMethod(req, res, "file" + file.getFileID());

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		File requestedFile = getRequestedFile(req, uriParser);

		if (requestedFile == null) {

			throw new URINotFoundException(uriParser);
		}

		checkLockAccess(user, requestedFile);

		TransactionHandler transactionHandler = null;

		try {

			transactionHandler = fileDAO.createTransaction();

			fileDAO.delete(requestedFile, transactionHandler);

			java.io.File file = new java.io.File(getSectionFilestore() + java.io.File.separator + requestedFile.getFileID() + "." + FileUtils.getFileExtension(requestedFile.getFilename()));

			if (file.exists()) {

				file.delete();

			}

			transactionHandler.commit();

			systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(requestedFile.getFileID().toString(), moduleDescriptor), EventTarget.ALL);

			if (sectionEventHandler != null) {

				sectionEventHandler.filterEvents(moduleDescriptor.getSectionID(), moduleDescriptor.getModuleID(), new FileEventFilter(requestedFile));
			}

			cacheCategory(requestedFile.getCategory().getCategoryID());

			log.info("User " + user + " deleted file " + requestedFile + " from section room " + sectionInterface.getSectionDescriptor());

			redirectToDefaultMethod(req, res, "category" + requestedFile.getCategory().getCategoryID());

			return null;

		} finally {

			TransactionHandler.autoClose(transactionHandler);
		}
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse downloadFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		File requestedFile = getRequestedFile(req, uriParser);

		if (requestedFile == null) {

			throw new URINotFoundException(uriParser);
		}

		log.info("User " + user + " downloading file '" + requestedFile + "' in section room " + sectionInterface.getSectionDescriptor());

		java.io.File file = new java.io.File(getFilePath(requestedFile));

		if (!file.exists()) {

			log.warn("Unable to find file " + file + " in section room " + sectionInterface.getSectionDescriptor());

			throw new URINotFoundException(uriParser);
		}

		try {
			HTTPUtils.sendFile(file, requestedFile.getFilename(), req, res, ContentDisposition.ATTACHMENT);
		} catch (IOException e) {

			log.info("Error sending file " + requestedFile + " to user " + user + ", " + e);
		}

		return null;

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse showImage(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		File requestedFile = getRequestedFile(req, uriParser);

		if (requestedFile == null) {

			throw new URINotFoundException(uriParser);
		}

		java.io.File file = new java.io.File(getFilePath(requestedFile));

		if (!file.exists()) {

			log.warn("Unable to find file " + file + " in section room " + sectionInterface.getSectionDescriptor());

			throw new URINotFoundException(uriParser);
		}

		if (!ImageUtils.isImage(requestedFile.getFilename())) {

			throw new URINotFoundException(uriParser);
		}

		log.info("User " + user + " requesting image '" + requestedFile + "' in section room " + sectionInterface.getSectionDescriptor());

		HTTPUtils.sendFile(file, requestedFile.getFilename(), req, res, ContentDisposition.INLINE);

		return null;

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse lockFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		File file = getRequestedFile(req, uriParser);

		if (file == null) {

			throw new URINotFoundException(uriParser);
		}

		if (file.getLocked() != null && file.getLockedBy() != null && !file.getLockedBy().equals(user)) {

			log.info("User " + user + " trying to lock file " + file + " even if its locked by user " + file.getLockedBy());

			throw new AccessDeniedException("Lock file access denied");
		}

		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(System.currentTimeMillis() + (fileLockTime * MillisecondTimeUnits.HOUR));
		calendar.set(Calendar.SECOND, 59);
		calendar.set(Calendar.MILLISECOND, 999);

		file.setLocked(new Timestamp(calendar.getTimeInMillis()));
		file.setLockedBy(user);

		fileDAO.update(file);

		cacheCategory(file.getCategory().getCategoryID());

		log.info("User " + user + " locked file " + file + " in section room " + sectionInterface.getSectionDescriptor());

		redirectToDefaultMethod(req, res, "file" + file.getFileID());

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse unLockFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		File file = getRequestedFile(req, uriParser);

		if (file == null) {

			throw new URINotFoundException(uriParser);
		}

		if (file.getLocked() != null) {

			if (file.getLockedBy() != null && !file.getLockedBy().equals(user) && !hasManageOtherContentAccess(user)) {

				log.info("User " + user + " trying to unlock file " + file + " even if its locked by user " + file.getLockedBy());

				throw new AccessDeniedException("Lock file access denied");
			}

			file.setLocked(null);
			file.setLockedBy(null);

			fileDAO.update(file);

			cacheCategory(file.getCategory().getCategoryID());

			log.info("User " + user + " unlocked file " + file + " in section room " + sectionInterface.getSectionDescriptor());

		}

		redirectToDefaultMethod(req, res, "file" + file.getFileID());

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse replaceFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		if (req.getMethod().equalsIgnoreCase("POST")) {

			MultipartRequest requestWrapper = null;

			TransactionHandler transactionHandler = null;

			ValidationException validationException = null;

			try {

				requestWrapper = new MultipartRequest(this.ramThreshold * BinarySizes.KiloByte, this.diskThreshold * BinarySizes.MegaByte, this.maxFileSize * BinarySizes.MegaByte, req);

				if (requestWrapper.getFileCount() == 0) {

					return defaultMethod(requestWrapper, res, user, uriParser, Collections.singletonList(new ValidationError("NoFileAttached")));
				}

				File file = getRequestedFile(requestWrapper, uriParser);

				if (file == null) {

					throw new URINotFoundException(uriParser);
				}

				checkLockAccess(user, file);

				FileItem fileItem = requestWrapper.getFiles().get(0);

				if (fileFilter.accept(fileItem)) {

					transactionHandler = fileDAO.createTransaction();

					file.setFilename(FileUtils.toValidHttpFilename(FilenameUtils.getName(fileItem.getName())));
					file.setSize(fileItem.getSize());
					file.setEditor(user);
					file.setUpdated(TimeUtils.getCurrentTimestamp());

					fileDAO.update(file, transactionHandler, null);

					try {

						java.io.File fileSystemFile = new java.io.File(getFilePath(file));

						fileItem.write(fileSystemFile);

					} catch (Exception e) {

						log.error("Error replacing file " + fileItem.getName() + " for file " + file + " for user " + user + " in section room " + getSectionID());

						transactionHandler.abort();

						return defaultMethod(requestWrapper, res, user, uriParser, Collections.singletonList(new ValidationError("UnableToReplaceFile")));
					}

					transactionHandler.commit();

					log.info("User " + user + " replaced file " + fileItem.getName() + " for file " + file + " in section room " + getSectionID());

					cacheCategory(file.getCategory().getCategoryID());

					systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemUpdateEvent(new FileSearchableItem(file, file.getCategory(), "/" + moduleDescriptor.getAlias() + "/#file" + file.getFileID(), new java.io.File(getFilePath(file))), moduleDescriptor), EventTarget.ALL);

					if (sectionEventHandler != null && eventFragmentTransformer != null) {

						sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getUpdatedEvent(file));
					}

					redirectToDefaultMethod(req, res, "file" + file.getFileID());

					return null;

				} else {

					log.info("Invalid file " + fileItem.getName() + " uploaded by user " + user);

					return defaultMethod(requestWrapper, res, user, uriParser, Collections.singletonList(new ValidationError("InvalidFileFormat")));

				}

			} catch (FileSizeLimitExceededException e) {

				validationException = new ValidationException(new ValidationError("FileSizeLimitExceeded"));

			} catch (SizeLimitExceededException e) {

				validationException = new ValidationException(new ValidationError("RequestSizeLimitExceeded"));

			} catch (FileUploadException e) {

				validationException = new ValidationException(new ValidationError("UnableToParseRequest"));

			} finally {

				if (requestWrapper != null) {
					requestWrapper.deleteFiles();
				}

				TransactionHandler.autoClose(transactionHandler);

			}

			return defaultMethod((requestWrapper != null ? requestWrapper : req), res, user, uriParser, validationException.getErrors());

		}

		return defaultMethod(req, res, user, uriParser);
	}

	@WebPublic(alias = "fileicon")
	public ForegroundModuleResponse getFileIcon(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		if (uriParser.size() != 3) {

			throw new URINotFoundException(uriParser);
		}

		FileIconHandler.streamIcon(uriParser.get(2), res);

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse getTags(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		if (tagCache != null) {

			tagCache.sendMatchingTagsAsJSON(req, res, tagHitCount);

			return null;
		}

		HTTPUtils.sendReponse(new JsonArray().toJson(), JsonUtils.getContentType(), res);

		return null;
	}

	private List<String> populateTags(HttpServletRequest req, User user, URIParser uriParser, boolean reqIsInUTF8) {

		String tags = req.getParameter("tags");

		List<String> populatedTags = null;

		if (tags != null) {

			populatedTags = new ArrayList<String>();

			if (reqIsInUTF8) {
				tags = StringUtils.parseUTF8(tags);
			}

			for (String tag : tags.split(",")) {

				String populatedTag = tag.trim();

				if (!StringUtils.isEmpty(populatedTag)) {
					populatedTags.add(populatedTag);
				}
			}

		}

		return populatedTags;
	}

	public void deleteFileSystemFiles(Category category) {

		if (category.getFiles() != null) {

			if (sectionEventHandler != null) {

				sectionEventHandler.filterEvents(moduleDescriptor.getSectionID(), moduleDescriptor.getModuleID(), new CategoryEventFilter(category));
			}

			for (File file : category.getFiles()) {

				systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(file.getFileID().toString(), moduleDescriptor), EventTarget.ALL);

				java.io.File systemFile = new java.io.File(getFilePath(file));

				if (systemFile.exists()) {

					systemFile.delete();
				}
			}
		}
	}

	private File getRequestedFile(HttpServletRequest req, URIParser uriParser) throws SQLException {

		Integer fileID = NumberUtils.toInt(req.getParameter("fileID"));

		fileID = fileID != null ? fileID : uriParser.getInt(2);

		if (fileID != null) {

			HighLevelQuery<File> query = new HighLevelQuery<File>(File.CATEGORY_RELATION);
			query.addParameter(fileIDParamFactory.getParameter(fileID));

			File file = fileDAO.get(query);

			if (file != null && file.getCategory().getSectionID().equals(getSectionID())) {

				return file;
			}

		}

		return null;
	}

	public void cacheCategories(List<Integer> categories) {

		if (categories != null) {

			for (Integer categoryID : categories) {

				cacheCategory(categoryID);
			}

		}

	}

	public synchronized void cacheCategory(Integer categoryID) {

		try {

			HighLevelQuery<Category> query = new HighLevelQuery<Category>(Category.FILES_RELATION);

			query.addParameter(sectionIDParameter);
			query.addParameter(categoryDAO.getParameterFactory().getParameter(categoryID));

			Category category = categoryDAO.getAnnotatedDAO().get(query);

			if (category != null) {

				if (category.getFiles() != null) {

					Collections.sort(category.getFiles());
				}

				List<Category> tempCategoryList = new ArrayList<Category>(categoryCacheList);

				categoryCacheMap.put(categoryID, category);
				tempCategoryList.remove(category);
				tempCategoryList.add(category);

				Collections.sort(tempCategoryList);

				categoryCacheList = new CopyOnWriteArrayList<Category>(tempCategoryList);

			}

		} catch (SQLException e) {

			log.error("Unable to cache category with id " + categoryID, e);
		}

	}

	public synchronized void deleteCategory(Category category) {

		categoryCacheMap.remove(category.getCategoryID());
		categoryCacheList.remove(category);

	}

	public Category getCachedCategory(Integer categoryID) {

		return categoryCacheMap.get(categoryID);
	}
	
	public Category getCachedCategory(String categoryName) {
		
		for(Category category : categoryCacheList){
			if(category.getName().equals(categoryName)){
				return category;
			}
		}

		return null;
	}

	public Category getCategory(Integer categoryID, boolean relations) throws SQLException {

		HighLevelQuery<Category> query = new HighLevelQuery<Category>();
		query.addParameter(categoryDAO.getParameterFactory().getParameter(categoryID));

		if (relations) {
			query.addRelation(Category.FILES_RELATION);
		}

		return categoryDAO.getAnnotatedDAO().get(query);
	}

	public boolean hasManageAccess(User user) {

		if (CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {

			return true;
		}

		return false;
	}

	public boolean hasManageOtherContentAccess(User user) {

		Role role = cbInterface.getRole(getSectionID(), user);

		if (role != null && role.hasUpdateOtherContentAccess()) {

			return true;
		}

		return false;
	}

	public void checkManageAccess(User user) throws AccessDeniedException {

		if (!hasManageAccess(user)) {

			throw new AccessDeniedException("Manage files access denied");
		}

	}

	public void checkLockAccess(User user, File file) throws AccessDeniedException {

		if (file.getLockedBy() != null && !file.getLockedBy().equals(user)) {

			throw new AccessDeniedException("Manage locked file access denied");
		}

	}

	@Override
	protected String getMethod(HttpServletRequest req, URIParser uriParser) {

		String uriMethod = null;

		if (uriParser.size() > 1) {

			uriMethod = uriParser.get(1);
		}

		String paramMethod = req.getParameter("method");

		if (!StringUtils.isEmpty(paramMethod)) {

			if (!StringUtils.isEmpty(uriMethod)) {

				req.setAttribute("redirectURI", uriParser.getFormattedURI());

			}

			return paramMethod;

		}

		return uriMethod;
	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		Element document = doc.getDocumentElement();
		
		XMLUtils.appendNewElement(doc, document, "maxFileSize", maxFileSize * BinarySizes.MegaByte);
		XMLUtils.appendNewElement(doc, document, "formattedMaxFileSize", maxFileSize + "MB");
		
		Role role = cbInterface.getRole(getSectionID(), user);

		if (CBAccessUtils.hasAddContentAccess(user, role)) {

			XMLUtils.appendNewElement(doc, document, "hasManageAccess", true);
		}

		if (role != null && role.hasUpdateOtherContentAccess()) {

			XMLUtils.appendNewElement(doc, document, "hasManageOtherContentAccess", true);
		}

		if (searchModule != null) {
			XMLUtils.appendNewElement(doc, document, "SearchModuleAlias", searchModule.getFullAlias());
		}
		
		return doc;
	}

	private String getSectionFilestore() {

		return baseFilestore + java.io.File.separator + getSectionID();
	}

	private String getFilePath(File file) {

		return getSectionFilestore() + java.io.File.separator + file.getFileID() + "." + FileUtils.getFileExtension(file.getFilename());
	}

	private String getFormattedDate(Date date) {

		return DateUtils.dateAndShortMonthToString(date, new Locale(systemInterface.getDefaultLanguage().getLanguageCode())) + " " + TimeUtils.TIME_FORMATTER.format(date);

	}

	private void appendFormattedDates(File file, Document doc, Element fileElement) {

		XMLUtils.appendNewElement(doc, fileElement, "formattedPostedDate", getFormattedDate(file.getPosted()));

		Timestamp updated = file.getUpdated();

		if (updated != null) {

			XMLUtils.appendNewElement(doc, fileElement, "formattedUpdatedDate", getFormattedDate(file.getUpdated()));
		}

	}
	
	private void checkCategories() throws SQLException {
		
		if(categoryCacheList.isEmpty()) {
			
			Category category = new Category();
			category.setName(autoCreatedCategoryName);
			category.setSectionID(getSectionID());
			category.setAutoGenerated(true);

			categoryDAO.add(category);
			
			cacheCategory(category.getCategoryID());
			
		}
		
	}

	@Override
	public List<? extends CBSearchableItem> getSearchableItems() throws Exception {

		if (categoryCacheList.isEmpty()) {

			return null;
		}

		List<FileSearchableItem> searchableItems = new ArrayList<FileSearchableItem>();

		for (Category category : categoryCacheList) {

			if (category.getFiles() == null) {

				continue;
			}

			for (File file : category.getFiles()) {

				searchableItems.add(new FileSearchableItem(file, category, "/" + moduleDescriptor.getAlias() + "/#file" + file.getFileID(), new java.io.File(getFilePath(file))));
			}
		}

		if (searchableItems.isEmpty()) {

			return null;
		}

		return searchableItems;
	}

	@Override
	public List<SectionEvent> getEvents(Timestamp breakpoint, int count) throws Exception {

		if (categoryCacheList.isEmpty()) {

			return null;
		}

		List<File> postedFiles = new ArrayList<File>();
		List<File> updatedFiles = new ArrayList<File>();

		for (Category category : categoryCacheList) {

			if (category.getFiles() == null) {

				continue;
			}

			if (breakpoint != null) {

				for (File file : category.getFiles()) {

					if (file.getPosted().after(breakpoint)) {

						postedFiles.add(file);
					}

					if (file.getUpdated() != null && file.getUpdated().after(breakpoint)) {

						updatedFiles.add(file);
					}
				}

			} else {

				postedFiles.addAll(category.getFiles());

				for (File file : category.getFiles()) {

					if (file.getUpdated() != null) {

						updatedFiles.add(file);
					}
				}
			}
		}

		if (postedFiles.isEmpty() && updatedFiles.isEmpty()) {

			return null;
		}

		List<SectionEvent> events = new ArrayList<SectionEvent>(NumberUtils.getLowestValue(postedFiles.size() + updatedFiles.size(), count));

		if (!postedFiles.isEmpty()) {

			if (postedFiles.size() > count) {

				Collections.sort(postedFiles, POSTED_COMPARATOR);

				postedFiles = postedFiles.subList(0, count);
			}

			for (File file : postedFiles) {

				events.add(getPostedEvent(file));
			}
		}

		if (!updatedFiles.isEmpty()) {

			if (updatedFiles.size() > count) {

				Collections.sort(updatedFiles, UPDATED_COMPARATOR);

				updatedFiles = updatedFiles.subList(0, count);
			}

			for (File file : updatedFiles) {

				events.add(getUpdatedEvent(file));
			}
		}

		return events;
	}

	@Override
	public ViewFragment getFragment(File file, EventFormat format, String fullContextPath, String eventType) throws Exception {

		ViewFragmentTransformer transformer = this.eventFragmentTransformer;

		if (transformer == null) {

			log.warn("No event fragment transformer available, unable to transform event for file " + file);
			return null;
		}

		if (log.isDebugEnabled()) {

			log.debug("Transforming event for file " + file);
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "FileURL", fullContextPath + this.getFullAlias() + "#file" + file.getFileID());

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		XMLUtils.appendNewElement(doc, documentElement, "EventType", eventType);
		documentElement.appendChild(file.toXML(doc));

		return transformer.createViewFragment(doc);
	}

	private SectionEvent getPostedEvent(File file) {

		return new TransformedSectionEvent<File>(moduleDescriptor.getModuleID(), file.getPosted(), file, this, FILE_POSTED_EVENT_TYPE);
	}

	private SectionEvent getUpdatedEvent(File file) {

		return new TransformedSectionEvent<File>(moduleDescriptor.getModuleID(), file.getUpdated(), file, this, FILE_UPDATED_EVENT_TYPE);
	}

	public List<File> getFiles(List<Integer> fileIDs) throws SQLException {

		HighLevelQuery<File> query = new HighLevelQuery<File>(File.CATEGORY_RELATION);
		query.addParameter(fileIDParamFactory.getWhereInParameter(fileIDs));

		List<File> files = fileDAO.getAll(query);

		if (files != null) {

			List<File> allowedFiles = new ArrayList<File>(files.size());

			for (File file : files) {

				if (file.getCategory().getSectionID().equals(getSectionID())) {

					allowedFiles.add(file);
				}

			}

			return allowedFiles;
		}

		return null;
	}

	@Override
	public List<ShortCut> getShortCuts(User user) {

		if (hasManageAccess(user)) {

			return Collections.singletonList(new ShortCut(shortCutText, shortCutText, this.getFullAlias()));

		}

		return null;
	}

	@Override
	public long getUsedStorage() {

		long usage = 0;

		for (Category category : categoryCacheList) {

			if (!CollectionUtils.isEmpty(category.getFiles())) {

				for (File file : category.getFiles()) {

					usage += file.getSize();
				}
			}
		}

		return usage;
	}
	
	public FileFilter getFileFilter(){
		return fileFilter;
	}

	public boolean addFile(Integer sectionID, String filename, String categoryName, byte[] content, User user) throws SQLException {
		
		TransactionHandler transactionHandler = categoryDAO.createTransaction();
		
		Timestamp timestamp = TimeUtils.getCurrentTimestamp();
		
		File file = new File();
		file.setFilename(filename);
		file.setSize((long) content.length);
		file.setPosted(timestamp);
		file.setPoster(user);
		
		if(StringUtils.isEmpty(categoryName)){
			categoryName = autoCreatedCategoryName;
		}
		
		Category category = getCachedCategory(categoryName);
		
		if(category == null){
			category = new Category();
			category.setName(categoryName);
			category.setSectionID(sectionID);
			categoryDAO.add(category, transactionHandler);
		}
		
		file.setCategory(category);
//		file.setTags(populateTags(requestWrapper, user, uriParser, true));

		fileDAO.add(file, transactionHandler, null);

		try {

			FileUtils.writeFile(getFilePath(file), content);

		} catch (Exception e) {

			transactionHandler.abort();

			log.error("Error adding file " + filename + " to category " + category + " uploaded by user " + user);

			return false;
		}

		transactionHandler.commit();

		log.info("User " + user + " uploaded file " + file + " to category " + category + " in section room " + getSectionID());

		cacheCategory(category.getCategoryID());

		if (file.getTags() != null) {

			tagCache.addTags(file.getTags());
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemAddEvent(new FileSearchableItem(file, category, "/" + moduleDescriptor.getAlias() + "/#file" + file.getFileID(), new java.io.File(getFilePath(file))), moduleDescriptor), EventTarget.ALL);

		if (sectionEventHandler != null && eventFragmentTransformer != null) {

			sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getPostedEvent(file));
		}
		
		return true;
	}

}
