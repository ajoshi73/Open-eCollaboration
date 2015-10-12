package se.sundsvall.collaborationroom.modules.blog;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.CBConstants;
import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.enums.EventFormat;
import se.dosf.communitybase.enums.NotificationFormat;
import se.dosf.communitybase.enums.SectionAccessMode;
import se.dosf.communitybase.events.CBSearchableItemAddEvent;
import se.dosf.communitybase.events.CBSearchableItemDeleteEvent;
import se.dosf.communitybase.events.CBSearchableItemUpdateEvent;
import se.dosf.communitybase.interfaces.CBSearchable;
import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.dosf.communitybase.interfaces.EventTransformer;
import se.dosf.communitybase.interfaces.Notification;
import se.dosf.communitybase.interfaces.NotificationHandler;
import se.dosf.communitybase.interfaces.NotificationTransformer;
import se.dosf.communitybase.interfaces.Posted;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.interfaces.SectionEventProvider;
import se.dosf.communitybase.interfaces.TagCache;
import se.dosf.communitybase.interfaces.TagProvider;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.search.SearchModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.dosf.communitybase.utils.CBSectionAttributeHelper;
import se.sundsvall.collaborationroom.modules.blog.beans.Comment;
import se.sundsvall.collaborationroom.modules.blog.beans.Post;
import se.sundsvall.collaborationroom.modules.blog.beans.PostSearchableItem;
import se.sundsvall.collaborationroom.modules.blog.cruds.CommentCRUD;
import se.sundsvall.collaborationroom.modules.blog.cruds.PostCRUD;
import se.sundsvall.collaborationroom.modules.filearchive.FileArchiveModule;
import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.annotations.XSLVariable;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.GenericCRUD;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryParameter;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.dao.querys.ArrayListQuery;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.json.JsonArray;
import se.unlogic.standardutils.json.JsonUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.populators.StringPopulator;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.xml.XMLGeneratorDocument;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.HTTPUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;

public class BlogModule extends CBBaseModule implements TagProvider, SectionEventProvider, EventTransformer<Post>, CBSearchable, NotificationTransformer, ShortCutProvider {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Post load count", description = "The number of posts to load on the firstpage and each time more posts are requested")
	private Integer postLoadCount = 5;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Tag hit count", description = "The number of tags to get from tag cache during auto complete queries")
	private Integer tagHitCount = 30;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Event stylesheet", description = "The stylesheet used to transform events")
	private String eventStylesheet = "BlogEvent.sv.xsl";

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Notification stylesheet", description = "The stylesheet used to transform notifications")
	private String notificationStylesheet = "BlogNotification.sv.xsl";

	@XSLVariable(prefix = "java.")
	private String shortCutText = "Add post";

	private AnnotatedDAO<Post> postDAO;

	private QueryParameterFactory<Post, Integer> postIDParamFactory;
	private QueryParameter<Post, Integer> sectionIDParameter;

	private PostCRUD postCRUD;
	private CommentCRUD commentCRUD;

	private ConcurrentHashMap<Integer, Post> postCacheMap;
	private CopyOnWriteArrayList<Post> postCacheList;

	@InstanceManagerDependency(required = false)
	protected UserProfileProvider userProfileProvider;

	@InstanceManagerDependency(required = true)
	protected TagCache tagCache;

	@InstanceManagerDependency(required = false)
	protected SearchModule searchModule;

	@InstanceManagerDependency(required = false)
	protected NotificationHandler notificationHandler;

	private SimpleViewFragmentTransformer eventFragmentTransformer;

	private SimpleViewFragmentTransformer notificationFragmentTransformer;

	private Integer sourceModuleID;

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, BlogModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		postDAO = daoFactory.getDAO(Post.class);

		postIDParamFactory = postDAO.getParamFactory("postID", Integer.class);

		QueryParameterFactory<Post, Integer> postSectionIDParamFactory = postDAO.getParamFactory("sectionID", Integer.class);

		AdvancedAnnotatedDAOWrapper<Post, Integer> postDAOWrapper = postDAO.getAdvancedWrapper(Integer.class);

		sectionIDParameter = postSectionIDParamFactory.getParameter(getSectionID());

		postDAOWrapper.getGetQuery().addParameter(sectionIDParameter);

		postCRUD = new PostCRUD(postDAOWrapper, this);

		AdvancedAnnotatedDAOWrapper<Comment, Integer> commentDAOWrapper = daoFactory.getDAO(Comment.class).getAdvancedWrapper(Integer.class);

		commentCRUD = new CommentCRUD(commentDAOWrapper, this);

		cachePosts();
	}

	@Override
	protected void moduleConfigured() throws Exception {

		super.moduleConfigured();

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

		if (notificationStylesheet == null) {

			log.warn("No stylesheet set for notification transformations");
			notificationFragmentTransformer = null;

		} else {

			try {
				notificationFragmentTransformer = new SimpleViewFragmentTransformer(notificationStylesheet, systemInterface.getEncoding(), this.getClass(), moduleDescriptor, sectionInterface);

			} catch (Exception e) {

				log.error("Error parsing stylesheet for notification transformations", e);
				notificationFragmentTransformer = null;
			}
		}

		sourceModuleID = moduleDescriptor.getAttributeHandler().getInt(CBConstants.MODULE_SOURCE_MODULE_ID_ATTRIBUTE);

		if (sourceModuleID == null) {

			log.warn("Module " + moduleDescriptor + " has no source module ID set in module descriptor attributes, disabling notification suppport.");
		}

		// TODO breadcrumb texts
	}

	protected void cachePosts() throws SQLException {

		HighLevelQuery<Post> query = new HighLevelQuery<Post>();

		query.addRelation(Post.COMMENTS_RELATION);
		query.addParameter(sectionIDParameter);

		List<Post> posts = postDAO.getAll(query);

		if (posts == null) {

			this.postCacheList = new CopyOnWriteArrayList<Post>();
			this.postCacheMap = new ConcurrentHashMap<Integer, Post>();

		} else {

			ConcurrentHashMap<Integer, Post> postMap = new ConcurrentHashMap<Integer, Post>();

			for (Post post : posts) {

				postMap.put(post.getPostID(), post);
			}

			Collections.sort(posts);

			this.postCacheList = new CopyOnWriteArrayList<Post>(posts);
			this.postCacheMap = postMap;
		}
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return defaultMethod(req, res, user, uriParser, null);
	}

	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("ListPosts");
		doc.getFirstChild().appendChild(listPostsElement);

		Role role = cbInterface.getRole(getSectionID(), user);

		if (!postCacheList.isEmpty()) {

			appendPosts(0, postLoadCount, doc, listPostsElement, user, role);
		}

		FileArchiveModule fileArchiveModule = getFileArchiveModule();

		if (fileArchiveModule != null) {

			if (req.getParameterValues("fileID") != null) {

				listPostsElement.appendChild(RequestUtils.getRequestParameters(req, doc));

				List<Integer> fileIDs = NumberUtils.toInt(req.getParameterValues("fileID"));

				if (fileIDs != null) {

					XMLUtils.append(doc, listPostsElement, "AttachedFiles", fileArchiveModule.getFiles(fileIDs));

				}

			}

		}

		if (validationErrors != null) {

			XMLUtils.append(doc, listPostsElement, validationErrors);
			listPostsElement.appendChild(RequestUtils.getRequestParameters(req, doc));

		}

		return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());

	}

	@WebPublic(alias = "getposts")
	public ForegroundModuleResponse loadAdditionalPosts(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer startIndex = uriParser.getInt(2);

		if (startIndex == null || uriParser.size() != 3) {

			throw new URINotFoundException(uriParser);
		}

		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("LoadAdditionalPosts");
		doc.getFirstChild().appendChild(listPostsElement);

		Role role = cbInterface.getRole(getSectionID(), user);

		if (!postCacheList.isEmpty() && (startIndex < postCacheList.size())) {

			appendPosts(startIndex, postLoadCount, doc, listPostsElement, user, role);
		}

		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		res.setHeader("Posts", "true");

		return moduleResponse;
	}

	public void appendBlogPosts(int startIndex, int postLoadCount, Document doc, Element targetElement, User user, Role role) {

		if (!postCacheList.isEmpty()) {

			appendPosts(startIndex, postLoadCount, doc, targetElement, user, role);
		}

	}

	private void appendPosts(int startIndex, int postLoadCount, Document doc, Element targetElement, User user, Role role) {

		if (postCacheList.size() <= startIndex) {

			return;
		}

		Element postsElement = doc.createElement("Posts");

		int index = startIndex;

		XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

		generatorDocument.addIgnoredField(Post.COMMENTS_RELATION);

		while (postsElement.getChildNodes().getLength() < postLoadCount && index < postCacheList.size()) {

			Post post;

			try {
				post = postCacheList.get(index);

			} catch (IndexOutOfBoundsException e) {

				//This is needed to properly handle concurrency where the list can shrink as we are iterating over it
				break;
			}

			Element postElement = post.toXML(generatorDocument);

			this.appendAttachedFiles(post, generatorDocument, postElement);
			this.appendBeanAccess(generatorDocument, postElement, user, post, role);

			Calendar calendar = Calendar.getInstance();
			calendar.setTime(post.getPosted());

			XMLUtils.appendNewElement(generatorDocument, postElement, "formattedPostedDate", getFormattedDate(post.getPosted()));

			postsElement.appendChild(postElement);

			index++;
		}

		targetElement.appendChild(postsElement);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addPost(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return postCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse follow(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Post post = postCRUD.getRequestedBean(req, res, user, uriParser, GenericCRUD.SHOW);

		if (post != null) {

			log.info("User " + user + " following post " + post);

			addFollower(post, user);

			sendFollowRequestRedirect(post, req, res);

			return null;

		}

		throw new URINotFoundException(uriParser);
	}

	public void addFollower(Post post, User user) throws SQLException {

		List<Integer> followers = post.getFollowers();

		if (followers == null) {

			followers = new ArrayList<Integer>(1);
		}

		if (!followers.contains(user.getUserID())) {

			followers.add(user.getUserID());

			post.setFollowers(followers);

			postDAO.update(post);

			cachePost(post.getPostID());
		}
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse unFollow(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Post post = postCRUD.getRequestedBean(req, res, user, uriParser, GenericCRUD.SHOW);

		if (post != null) {

			log.info("User " + user + " unfollowing post " + post);

			List<Integer> followers = post.getFollowers();

			if (followers != null) {

				followers.remove(user.getUserID());

				post.setFollowers(followers);

				postDAO.update(post);

				cachePost(post.getPostID());

			}

			sendFollowRequestRedirect(post, req, res);

			return null;

		}

		throw new URINotFoundException(uriParser);
	}

	private void sendFollowRequestRedirect(Post post, HttpServletRequest req, HttpServletResponse res) throws IOException {

		String mode = req.getParameter("mode");

		if (mode != null && mode.equalsIgnoreCase("SHOW")) {
			redirectToMethod(req, res, "/show/" + post.getPostID());
		} else {
			redirectToDefaultMethod(req, res, "p" + post.getPostID());
		}

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updatePost(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return postCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deletePost(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return postCRUD.delete(req, res, user, uriParser);
	}

	@WebPublic(alias = "show")
	public ForegroundModuleResponse showPost(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return postCRUD.show(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addComment(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return commentCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateComment(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return commentCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteComment(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		return commentCRUD.delete(req, res, user, uriParser);
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

	public Post getCachedPost(Integer beanID) {

		return postCacheMap.get(beanID);
	}

	public synchronized void cachePost(Integer postID) throws SQLException {

		HighLevelQuery<Post> query = new HighLevelQuery<Post>(Post.COMMENTS_RELATION);

		query.addParameter(postIDParamFactory.getParameter(postID));
		query.addParameter(sectionIDParameter);

		Post post = postDAO.get(query);

		if (post != null) {

			List<Post> tempPostCacheList = new ArrayList<Post>(postCacheList);

			postCacheMap.put(postID, post);
			tempPostCacheList.remove(post);
			tempPostCacheList.add(post);

			Collections.sort(tempPostCacheList);

			postCacheList = new CopyOnWriteArrayList<Post>(tempPostCacheList);
		}
	}

	public void uncachePost(Integer postID) {

		Post post = postCacheMap.remove(postID);

		if (post != null) {

			postCacheList.remove(post);
		}
	}

	public PostCRUD getPostCRUD() {

		return postCRUD;
	}

	public String getFormattedDate(Date date) {

		return DateUtils.dateAndShortMonthToString(date, new Locale(systemInterface.getDefaultLanguage().getLanguageCode())) + " " + TimeUtils.TIME_FORMATTER.format(date);

	}

	public String getLanguageCode() {

		return systemInterface.getDefaultLanguage().getLanguageCode();
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
	public List<SectionEvent> getEvents(Timestamp breakpoint, int count) throws Exception {

		if (eventFragmentTransformer == null) {

			log.warn("No event fragment transformer available, ignoring request for events");
			return null;
		}

		if (postCacheList.isEmpty()) {

			return null;
		}

		ArrayList<SectionEvent> eventList = new ArrayList<SectionEvent>(NumberUtils.getLowestValue(count, postCacheList.size()));

		for (Post post : postCacheList) {

			if (eventList.size() >= count || (breakpoint != null && breakpoint.before(post.getPosted()))) {

				break;
			}

			eventList.add(new TransformedSectionEvent<Post>(moduleDescriptor.getModuleID(), post.getPosted(), post, this, null));
		}

		return eventList;
	}

	@Override
	public ViewFragment getFragment(Post post, EventFormat format, String fullContextPath, String eventType) throws Exception {

		ViewFragmentTransformer transformer = this.eventFragmentTransformer;

		if (transformer == null) {

			log.warn("No event fragment transformer available, unable to transform event for post " + post);
			return null;
		}

		if (log.isDebugEnabled()) {

			log.debug("Transforming event for post " + post);
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "PostURL", fullContextPath + this.getFullAlias() + "/show/" + post.getPostID());

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		documentElement.appendChild(post.toXML(doc));

		return transformer.createViewFragment(doc);
	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		Element document = doc.getDocumentElement();

		if (userProfileProvider != null) {
			XMLUtils.appendNewElement(doc, document, "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, document, "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		if (searchModule != null) {
			XMLUtils.appendNewElement(doc, document, "SearchModuleAlias", searchModule.getFullAlias());
		}

		FileArchiveModule fileArchiveModule = getFileArchiveModule();

		if (fileArchiveModule != null) {

			XMLUtils.appendNewElement(doc, document, "FileArchiveModuleAlias", fileArchiveModule.getFullAlias());
		}

		if (hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "hasAddAccess", true);
		}

		XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "serverURL", RequestUtils.getServerURL(req));

		return doc;
	}

	public boolean hasAddContentAccess(User user, Role role) {

		if (CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {

			return true;

		}

		return hasAnonymousCRUDAccess(user, null);
	}

	public boolean hasUpdateContentAccess(User user, Posted bean, Role role) {

		if (CBAccessUtils.hasUpdateContentAccess(user, bean, role)) {

			return true;
		}

		return hasAnonymousCRUDAccess(user, bean);
	}

	public boolean hasDeleteContentAccess(User user, Posted bean, Role role) {

		if (CBAccessUtils.hasDeleteContentAccess(user, bean, role)) {

			return true;
		}

		return hasAnonymousCRUDAccess(user, bean);
	}

	private boolean hasAnonymousCRUDAccess(User user, Posted bean) {

		SectionAccessMode accessMode = CBSectionAttributeHelper.getAccessMode(getSectionDescriptor());

		if (accessMode != null && accessMode.equals(SectionAccessMode.OPEN)) {

			if (bean == null || (bean != null && bean.getPoster() != null && bean.getPoster().equals(user))) {

				return true;
			}

		}

		return false;
	}

	public void appendBeanAccess(Document doc, Element targetElement, User user, Posted bean, Role role) {

		if (hasUpdateContentAccess(user, bean, role)) {
			XMLUtils.appendNewElement(doc, targetElement, "hasUpdateAccess", true);
		}

		if (hasDeleteContentAccess(user, bean, role)) {
			XMLUtils.appendNewElement(doc, targetElement, "hasDeleteAccess", true);
		}

	}

	@Override
	public List<String> getTags() throws SQLException {

		return new ArrayListQuery<String>(dataSource, "SELECT DISTINCT tag FROM " + Post.POST_TAG_TABLE, StringPopulator.getPopulator()).executeQuery();
	}

	public void postAdded(Post post) throws SQLException {

		cachePost(post.getPostID());

		if (post.getTags() != null) {

			tagCache.addTags(post.getTags());
		}

		if (sectionEventHandler != null && eventFragmentTransformer != null) {

			sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getSectionEvent(post));
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemAddEvent(getSearchableItem(post), moduleDescriptor), EventTarget.ALL);
	}

	public void postUpdated(Post post) throws SQLException {

		cachePost(post.getPostID());

		if (post.getTags() != null) {

			tagCache.addTags(post.getTags());
		}

		if (sectionEventHandler != null && eventFragmentTransformer != null) {

			sectionEventHandler.replaceEvent(moduleDescriptor.getSectionID(), getSectionEvent(post));
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemUpdateEvent(getSearchableItem(post), moduleDescriptor), EventTarget.ALL);
	}

	public void postDeleted(Post post) {

		uncachePost(post.getPostID());

		if (sectionEventHandler != null) {

			sectionEventHandler.removeEvent(moduleDescriptor.getSectionID(), getSectionEvent(post));
		}

		if (notificationHandler != null && sourceModuleID != null) {

			try {
				notificationHandler.deleteNotifications(moduleDescriptor.getSectionID(), sourceModuleID, post.getPostID(), null);
			} catch (SQLException e) {

				log.error("Error deleting notifications for post " + post, e);
			}
		}

		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(post.getPostID().toString(), moduleDescriptor), EventTarget.ALL);
	}

	private SectionEvent getSectionEvent(Post post) {

		return new TransformedSectionEvent<Post>(moduleDescriptor.getModuleID(), post.getPosted(), post, this, null);
	}

	@Override
	public List<? extends CBSearchableItem> getSearchableItems() throws Exception {

		if (this.postCacheList != null) {

			List<CBSearchableItem> searchableItems = new ArrayList<CBSearchableItem>(postCacheList.size());

			for (Post post : postCacheList) {

				searchableItems.add(getSearchableItem(post));
			}

			return searchableItems;
		}

		return null;
	}

	private CBSearchableItem getSearchableItem(Post post) {

		return new PostSearchableItem(post, "/" + moduleDescriptor.getAlias() + "/show/" + post.getPostID());
	}

	public void commentAdded(Comment comment) throws SQLException {

		addFollower(comment.getPost(), comment.getPoster());

		if (notificationHandler != null && sourceModuleID != null && comment.getPost().getFollowers() != null) {

			try {
				Integer sectionID = moduleDescriptor.getSectionID();

				for (Integer userID : comment.getPost().getFollowers()) {

					if (comment.getPoster().getUserID().equals(userID)) {

						continue;
					}

					//Check if the followers has any unread notifications for this post
					Notification notification = notificationHandler.getNotification(userID, sectionID, sourceModuleID, comment.getPost().getPostID(), null, false);

					if (notification == null) {

						//No unread notification found, add a new notification using the commentID as notification type since the module only produces one type of notifications
						notificationHandler.addNotification(userID, sectionID, sourceModuleID, comment.getCommentID().toString(), comment.getPost().getPostID(), null);
					}
				}

			} catch (Exception e) {

				log.error("Error adding notification for added comment " + comment, e);
			}
		}
	}

	public void commentDeleted(Comment comment) {

		if (notificationHandler != null && sourceModuleID != null) {

			try {
				Integer sectionID = moduleDescriptor.getSectionID();

				Post cachedPost = postCacheMap.get(comment.getPost().getPostID());

				if (cachedPost != null && cachedPost.getComments() != null) {

					//Check if there is a newer comment we can create notifications for instead
					for (Comment currentComment : cachedPost.getComments()) {

						if (currentComment.getPosted().after(comment.getPosted())) {

							//Match found, check if there are any unread notifications to replace
							List<? extends Notification> notifications = notificationHandler.getNotifications(sectionID, sourceModuleID, cachedPost.getPostID(), comment.getCommentID().toString(), false);

							if (notifications != null) {

								for (Notification notification : notifications) {

									//Add new notifications for the next comment instead of this one
									notificationHandler.addNotification(notification.getUserID(), sectionID, sourceModuleID, currentComment.getCommentID().toString(), cachedPost.getPostID(), null);
								}
							}

							break;
						}
					}
				}

				//Delete any notifications for this comment
				notificationHandler.deleteNotifications(sectionID, sourceModuleID, comment.getPost().getPostID(), comment.getCommentID().toString());

			} catch (Exception e) {

				log.error("Error updating/deleting notifications for deleted comment " + comment, e);
			}
		}
	}

	@Override
	public ViewFragment getFragment(Notification notification, NotificationFormat format, String fullContextPath) throws Exception {

		ViewFragmentTransformer transformer = this.notificationFragmentTransformer;

		if (transformer == null) {

			log.warn("No event fragment transformer available, unable to transform notification " + notification);
			return null;
		}

		if (log.isDebugEnabled()) {

			log.debug("Transforming notification " + notification);
		}

		Integer commentID = NumberUtils.toInt(notification.getNotificationType());

		if (commentID == null) {

			log.warn("Unable to parse comment ID in notification " + notification);
			return null;
		}

		Comment comment = commentCRUD.getBean(commentID, GenericCRUD.UPDATE, null);

		if (comment == null) {

			log.warn("Unable to find comment with ID " + commentID + " skipping notification " + notification);
			return null;
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);
		XMLUtils.appendNewElement(doc, documentElement, "FullAlias", this.getFullAlias());

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);

		documentElement.appendChild(comment.toXML(doc));
		XMLUtils.appendNewElement(doc, documentElement, "SectionName", sectionInterface.getSectionDescriptor().getName());
		XMLUtils.appendNewElement(doc, documentElement, "ModuleName", moduleDescriptor.getName());

		if (!notification.isRead()) {

			XMLUtils.appendNewElement(doc, documentElement, "Unread");
		}

		return transformer.createViewFragment(doc);
	}

	public void appendAttachedFiles(Post post, Document doc, Element postElement) {

		if (post.getLinkedFiles() != null) {

			FileArchiveModule fileArchiveModule = getFileArchiveModule();

			if (fileArchiveModule != null) {

				try {

					XMLUtils.append(doc, postElement, "AttachedFiles", fileArchiveModule.getFiles(post.getLinkedFiles()));

				} catch (SQLException e) {

					log.error("Unable to get attached files for post " + post, e);
				}

			}

		}

	}

	public FileArchiveModule getFileArchiveModule() {

		Entry<ForegroundModuleDescriptor, FileArchiveModule> fileArchiveEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(FileArchiveModule.class);

		if (fileArchiveEntry != null) {

			return fileArchiveEntry.getValue();
		}

		return null;
	}

	@Override
	public List<ShortCut> getShortCuts(User user) {

		if (hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {

			return Collections.singletonList(new ShortCut(shortCutText, shortCutText, this.getFullAlias() + "#add"));

		}

		return null;
	}
}
