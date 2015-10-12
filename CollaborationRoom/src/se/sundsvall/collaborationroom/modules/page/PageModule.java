package se.sundsvall.collaborationroom.modules.page;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

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
import se.dosf.communitybase.interfaces.SectionEventProvider;
import se.dosf.communitybase.interfaces.StorageUsage;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.page.beans.Page;
import se.sundsvall.collaborationroom.modules.page.beans.PageSearchableItem;
import se.sundsvall.collaborationroom.modules.page.cruds.PageCRUD;
import se.sundsvall.collaborationroom.modules.page.utils.MenuItemDescriptorComparator;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.annotations.XSLVariable;
import se.unlogic.hierarchy.core.beans.SimpleBundleDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleMenuItemDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.enums.MenuItemType;
import se.unlogic.hierarchy.core.enums.URLType;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.interfaces.BundleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.MenuItemDescriptor;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.FCKConnector;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.crud.AbsoluteFileURLProvider;
import se.unlogic.hierarchy.core.utils.crud.HTMLContentRewriteBeanFilter;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryParameter;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.io.FileUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class PageModule extends CBBaseModule implements AbsoluteFileURLProvider<Page>, SectionEventProvider, EventTransformer<Page>, CBSearchable, StorageUsage {

	@ModuleSetting(allowsNull = true)
	@TextFieldSettingDescriptor(name = "Base file store path", description = "Path to the directory to be used as base filestore for this module", required = true)
	private String baseFilestore;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Max upload size", description = "Maxmium upload size in megabytes allowed in a single post request", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private Integer diskThreshold = 100;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "RAM threshold", description = "Maximum size of files in KB to be buffered in RAM during file uploads. Files exceeding the threshold are written to disk instead.", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private Integer ramThreshold = 500;

	@ModuleSetting(allowsNull = true)
	@TextFieldSettingDescriptor(name = "Editor CSS", description = "Path to the desired CSS stylesheet for CKEditor (relative from the contextpath)", required = false)
	private String cssPath;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Event stylesheet", description = "The stylesheet used to transform events")
	private String eventStylesheet = "PageEvent.sv.xsl";

	@XSLVariable(prefix = "java.")
	private String addPageMenuItemName = "Add page";
	
	@XSLVariable(prefix = "java.")
	private String addPageMenuItemDescription = "Add page";
	
	private QueryParameterFactory<Page, Integer> pageIDParamFactory;

	private QueryParameter<Page, Integer> sectionIDParameter;

	private PageCRUD pageCRUD;

	private ConcurrentHashMap<Integer, Page> pageCacheMap;

	private ConcurrentHashMap<Integer, MenuItemDescriptor> menuItemCacheMap;

	private AnnotatedDAO<Page> pageDAO;

	private FCKConnector connector;

	private SimpleViewFragmentTransformer eventFragmentTransformer;

	@InstanceManagerDependency(required=false)
	protected UserProfileProvider userProfileProvider;

	@Override
	protected void moduleConfigured() throws Exception {

		super.moduleConfigured();

		if (baseFilestore != null) {

			String filestore = baseFilestore + "/" + getSectionID();

			File file = new File(filestore);

			if (!file.isDirectory()) {

				if (!file.mkdir()) {

					log.error("Unable to create filestore folder for module " + moduleDescriptor);

				} else {

					connector = new FCKConnector(filestore, diskThreshold, ramThreshold);
				}

			} else {

				connector = new FCKConnector(filestore, diskThreshold, ramThreshold);
			}

		} else {

			log.warn("No filestore configured, check modulesettings");
		}

		if(eventStylesheet == null){

			log.warn("No stylesheet set for event transformations");
			eventFragmentTransformer = null;

		}else{

			try{
				eventFragmentTransformer = new SimpleViewFragmentTransformer(eventStylesheet, systemInterface.getEncoding(), this.getClass(), moduleDescriptor, sectionInterface);

			}catch(Exception e){

				log.error("Error parsing stylesheet for event transformations",e);
				eventFragmentTransformer = null;
			}
		}
	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, PageModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		pageDAO = daoFactory.getDAO(Page.class);

		pageIDParamFactory = pageDAO.getParamFactory("pageID", Integer.class);

		QueryParameterFactory<Page, Integer> pageSectionIDParamFactory = pageDAO.getParamFactory("sectionID", Integer.class);

		sectionIDParameter = pageSectionIDParamFactory.getParameter(getSectionID());

		AdvancedAnnotatedDAOWrapper<Page, Integer> pageDAOWrapper = pageDAO.getAdvancedWrapper(Integer.class);

		pageDAOWrapper.getGetQuery().addParameter(sectionIDParameter);

		pageCRUD = new PageCRUD(pageDAOWrapper, this);
		pageCRUD.addBeanFilter(new HTMLContentRewriteBeanFilter<Page>(this));

		cachePages();
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkConfiguration();

		return add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse add(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return pageCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse update(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return pageCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse delete(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return pageCRUD.delete(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse show(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return pageCRUD.show(req, res, user, uriParser);
	}

	@WebPublic
	public ForegroundModuleResponse connector(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws IOException, AccessDeniedException {

		checkConfiguration();

		this.connector.processRequest(req, res, uriParser, user, moduleDescriptor);

		return null;
	}

	@WebPublic
	public ForegroundModuleResponse file(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkConfiguration();

		this.connector.processFileRequest(req, res, user, uriParser, moduleDescriptor, sectionInterface, 2, null);

		return null;
	}

	protected void cachePages() throws SQLException {

		log.info("Caching pages");

		HighLevelQuery<Page> query = new HighLevelQuery<Page>();

		query.addParameter(sectionIDParameter);

		List<Page> pages = pageDAO.getAll(query);

		if (pages == null) {

			pageCacheMap = new ConcurrentHashMap<Integer, Page>();
			menuItemCacheMap = new ConcurrentHashMap<Integer, MenuItemDescriptor>();

		} else {

			menuItemCacheMap = new ConcurrentHashMap<Integer, MenuItemDescriptor>(pages.size());

			ConcurrentHashMap<Integer, Page> pageMap = new ConcurrentHashMap<Integer, Page>();

			for (Page page : pages) {

				pageMap.put(page.getPageID(), page);

				cacheMenuItem(page, false);
			}

			pageCacheMap = pageMap;
		}

	}

	public Page getCachedPage(Integer pageID) {

		return pageCacheMap.get(pageID);
	}

	public synchronized void cachePage(Integer pageID) throws SQLException {

		HighLevelQuery<Page> query = new HighLevelQuery<Page>();

		query.addParameter(pageIDParamFactory.getParameter(pageID));
		query.addParameter(sectionIDParameter);

		Page page = pageDAO.get(query);

		if (page != null) {

			pageCacheMap.put(pageID, page);

			cacheMenuItem(page, true);
		}

	}

	public void uncachePage(Integer pageID) {

		Page page = pageCacheMap.remove(pageID);

		if (page != null) {

			pageCacheMap.remove(page);

			uncacheMenuItem(page);
		}
	}

	@Override
	public String getAbsoluteFileURL(URIParser uriParser, Page bean) {

		return uriParser.getCurrentURI(true) + "/" + this.moduleDescriptor.getAlias() + "/file";
	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "cssPath", cssPath);

		if(CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "hasAddAccess", true);
		}

		return doc;
	}

	@Override
	public List<? extends MenuItemDescriptor> getVisibleMenuItems() {

		return null;
	}

	@Override
	public List<? extends BundleDescriptor> getVisibleBundles() {

		SimpleBundleDescriptor bundle = new SimpleBundleDescriptor();
		bundle.setName(moduleDescriptor.getName());
		bundle.setUniqueID("pagesbundle" + getSectionID());
		bundle.setDescription(moduleDescriptor.getDescription());
		bundle.setItemType(MenuItemType.TITLE);
		bundle.setAccess(moduleDescriptor);

		ArrayList<MenuItemDescriptor> menuItemDescriptors = new ArrayList<MenuItemDescriptor>(menuItemCacheMap.values().size() + 1);

		menuItemDescriptors.addAll(menuItemCacheMap.values());

		Collections.sort(menuItemDescriptors, MenuItemDescriptorComparator.getInstance());

		SimpleMenuItemDescriptor menuItemDescriptor = new SimpleMenuItemDescriptor();
		menuItemDescriptor.setName(addPageMenuItemName);
		menuItemDescriptor.setDescription(addPageMenuItemDescription);
		menuItemDescriptor.setItemType(MenuItemType.MENUITEM);
		menuItemDescriptor.setAccess(moduleDescriptor);
		menuItemDescriptor.setUrl(getFullAlias() + "/add");
		menuItemDescriptor.setUrlType(URLType.RELATIVE_FROM_CONTEXTPATH);
		menuItemDescriptor.setUniqueID("pagesbundle" + getSectionID());
		menuItemDescriptors.add(0, menuItemDescriptor);

		bundle.setMenuItemDescriptors(menuItemDescriptors);

		return Arrays.asList(bundle);
	}

	private void cacheMenuItem(Page page, boolean updateSectionMenuCache) {

		SimpleMenuItemDescriptor menuItemDescriptor = new SimpleMenuItemDescriptor();

		menuItemDescriptor.setName(page.getTitle());
		menuItemDescriptor.setDescription(page.getTitle());
		menuItemDescriptor.setItemType(MenuItemType.MENUITEM);
		menuItemDescriptor.setAccess(moduleDescriptor);
		menuItemDescriptor.setUrl(getFullAlias() + "/show/" + page.getPageID());
		menuItemDescriptor.setUrlType(URLType.RELATIVE_FROM_CONTEXTPATH);
		menuItemDescriptor.setUniqueID("pagesbundle" + getSectionID());

		menuItemCacheMap.put(page.getPageID(), menuItemDescriptor);

		if (updateSectionMenuCache) {
			updateSectionMenuItemCache();
		}

	}

	private void uncacheMenuItem(Page page) {

		menuItemCacheMap.remove(page.getPageID());

		updateSectionMenuItemCache();
	}

	private void updateSectionMenuItemCache() {

		sectionInterface.getMenuCache().moduleUpdated(moduleDescriptor, this);

	}

	private void checkConfiguration() {

		if (connector == null) {

			throw new RuntimeException("Module is not properly configured, please check modulesettings");
		}

	}

	public String getLanguageCode() {

		return systemInterface.getDefaultLanguage().getLanguageCode();
	}

	public String getFormattedDate(Date date) {

		return DateUtils.dateAndShortMonthToString(date, new Locale(systemInterface.getDefaultLanguage().getLanguageCode())) + " " + TimeUtils.TIME_FORMATTER.format(date);

	}

	@Override
	protected String getMethod(HttpServletRequest req, URIParser uriParser) {

		String uriMethod = null;

		if (uriParser.size() > 1) {

			uriMethod = uriParser.get(1);
		}

		String paramMethod = req.getParameter("method");

		if(!StringUtils.isEmpty(paramMethod)) {

			if(!StringUtils.isEmpty(uriMethod)) {
				req.setAttribute("redirectURI", uriParser.getFormattedURI());
			}

			return paramMethod;

		}

		return uriMethod;
	}

	@Override
	public List<SectionEvent> getEvents(Timestamp breakpoint, int count) throws Exception {

		if(eventFragmentTransformer == null){

			log.warn("No event fragment transformer available, ignoring request for events");
			return null;
		}

		if(pageCacheMap.isEmpty()){

			return null;
		}

		ArrayList<SectionEvent> eventList = new ArrayList<SectionEvent>(NumberUtils.getLowestValue(count, pageCacheMap.size()));

		for(Page page : pageCacheMap.values()){

			if(eventList.size() >= count || (breakpoint != null && breakpoint.before(page.getPosted()))){

				break;
			}

			eventList.add(new TransformedSectionEvent<Page>(moduleDescriptor.getModuleID(), page.getPosted(), page, this, null));
		}

		return eventList;
	}

	@Override
	public ViewFragment getFragment(Page page, EventFormat format, String fullContextPath, String eventType) throws Exception {

		ViewFragmentTransformer transformer = this.eventFragmentTransformer;

		if(transformer == null){

			log.warn("No event fragment transformer available, unable to transform event for page " + page);
			return null;
		}

		if(log.isDebugEnabled()){

			log.debug("Transforming event for page " + page);
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		if(userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "PageURL", fullContextPath + this.getFullAlias() + "/show/" + page.getPageID());

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		documentElement.appendChild(page.toXML(doc));

		return transformer.createViewFragment(doc);
	}

	public void pageAdded(Page page) throws SQLException {

		cachePage(page.getPageID());

		if(sectionEventHandler != null && eventFragmentTransformer != null){

			sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getSectionEvent(page));
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemAddEvent(getSearchableItem(page), moduleDescriptor), EventTarget.ALL);
	}

	public void pageUpdated(Page page) throws SQLException {

		cachePage(page.getPageID());

		if(sectionEventHandler != null && eventFragmentTransformer != null){

			sectionEventHandler.replaceEvent(moduleDescriptor.getSectionID(), getSectionEvent(page));
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemUpdateEvent(getSearchableItem(page), moduleDescriptor), EventTarget.ALL);
	}

	public void pageDeleted(Page page) {

		uncachePage(page.getPageID());

		if(sectionEventHandler != null){

			sectionEventHandler.removeEvent(moduleDescriptor.getSectionID(), getSectionEvent(page));
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(page.getPageID().toString(), moduleDescriptor), EventTarget.ALL);
	}

	private SectionEvent getSectionEvent(Page page) {

		return new TransformedSectionEvent<Page>(moduleDescriptor.getModuleID(), page.getPosted(), page, this, null);
	}

	@Override
	public List<PageSearchableItem> getSearchableItems() throws Exception {

		if(!pageCacheMap.isEmpty()){

			List<PageSearchableItem> searchableItems = new ArrayList<PageSearchableItem>(pageCacheMap.size());

			for(Page page : pageCacheMap.values()){

				searchableItems.add(getSearchableItem(page));
			}

			return searchableItems;
		}

		return null;
	}

	private PageSearchableItem getSearchableItem(Page page) {

		return new PageSearchableItem(page, "/" + moduleDescriptor.getAlias() + "/show/" + page.getPageID());
	}

	@Override
	public long getUsedStorage() {

		if (StringUtils.isEmpty(baseFilestore)) {
			return 0;
		}
		
		File filestore = new File(baseFilestore + File.separator + getSectionID());
		
		if (!FileUtils.isReadable(filestore)) {
			return 0;
		}

		return org.apache.commons.io.FileUtils.sizeOfDirectory(filestore);
	}
}
