package se.sundsvall.collaborationroom.modules.blog;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.modules.search.SearchModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.blog.beans.Post;
import se.sundsvall.collaborationroom.modules.filearchive.FileArchiveModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.foregroundmodules.AnnotatedForegroundModule;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.MySQLRowLimiter;
import se.unlogic.standardutils.dao.OrderByCriteria;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.enums.Order;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.xml.XMLGeneratorDocument;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;

public class LatestUserPostsModule extends AnnotatedForegroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Post load count", description = "The number of posts to load on the firstpage and each time more posts are requested")
	private Integer postLoadCount = 5;

	@InstanceManagerDependency(required = true)
	private CBInterface cbInterface;

	@InstanceManagerDependency(required = false)
	private UserProfileProvider userProfileProvider;

	@InstanceManagerDependency(required = false)
	protected SearchModule searchModule;

	private AnnotatedDAO<Post> postDAO;

	private QueryParameterFactory<Post, Integer> sectionIDParamFactory;
	private OrderByCriteria<Post> postedOrderByCriteria;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		if (!systemInterface.getInstanceHandler().addInstance(LatestUserPostsModule.class, this)) {

			log.warn("Unable to register module " + moduleDescriptor + " in instance handler, another module is already registered for class " + LatestUserPostsModule.class.getName());
		}
	}

	@Override
	public void unload() throws Exception {

		systemInterface.getInstanceHandler().removeInstance(LatestUserPostsModule.class, this);

		super.unload();
	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		postDAO = daoFactory.getDAO(Post.class);

		sectionIDParamFactory = postDAO.getParamFactory("sectionID", Integer.class);

		postedOrderByCriteria = postDAO.getOrderByCriteria("posted", Order.DESC);
	}

	@WebPublic(alias = "getposts")
	public ForegroundModuleResponse loadAdditionalPosts(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer startIndex = uriParser.getInt(2);

		if (startIndex == null) {

			throw new URINotFoundException(uriParser);
		}

		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("LoadAdditionalPosts");
		doc.getFirstChild().appendChild(listPostsElement);

		appendPosts(startIndex, doc, listPostsElement, user);

		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		res.setHeader("Posts", "true");

		return moduleResponse;
	}
	
	public void appendPosts(int startIndex, Document doc, Element targetElement, User user) throws SQLException {

		List<Integer> sectionIDs = CBAccessUtils.getUserSections(user);

		if (sectionIDs != null) {

			List<Integer> addedSections = new ArrayList<Integer>(sectionIDs.size());

			Element sectionsElement = XMLUtils.appendNewElement(doc, targetElement, "BlogModules");

			Map<Integer, FileArchiveModule> fileArchiveModules = new HashMap<Integer, FileArchiveModule>(sectionIDs.size());

			for (Integer sectionID : sectionIDs) {

				Element sectionElement = XMLUtils.appendNewElement(doc, sectionsElement, "BlogModule");

				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

				if (sectionInterface != null) {

					Entry<ForegroundModuleDescriptor, BlogModule> blogModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(BlogModule.class);

					if (blogModuleEntry != null) {

						XMLUtils.appendNewElement(doc, sectionElement, "sectionID", sectionID);
						XMLUtils.appendNewElement(doc, sectionElement, "sectionName", sectionInterface.getSectionDescriptor().getName());
						XMLUtils.appendNewElement(doc, sectionElement, "fullAlias", sectionInterface.getSectionDescriptor().getFullAlias() + "/" + blogModuleEntry.getKey().getAlias());

						blogModuleEntry.getKey().getAlias();

						FileArchiveModule fileArchiveModule = blogModuleEntry.getValue().getFileArchiveModule();

						if (fileArchiveModule != null) {

							fileArchiveModules.put(sectionID, fileArchiveModule);
						}

						addedSections.add(sectionID);

					}

				}

			}

			Element postsElement = doc.createElement("Posts");

			XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

			generatorDocument.addIgnoredField(Post.COMMENTS_RELATION);

			HighLevelQuery<Post> query = new HighLevelQuery<Post>(Post.COMMENTS_RELATION);

			query.addOrderByCriteria(postedOrderByCriteria);
			query.addParameter(sectionIDParamFactory.getWhereInParameter(sectionIDs));
			query.setRowLimiter(new MySQLRowLimiter(startIndex, postLoadCount));

			List<Post> posts = postDAO.getAll(query);

			if (posts != null) {

				for (Post post : posts) {

					Element postElement = post.toXML(generatorDocument);

					appendAttachedFiles(post, generatorDocument, postElement, fileArchiveModules);

					CBAccessUtils.appendBeanAccess(generatorDocument, postElement, user, post, cbInterface.getRole(post.getSectionID(), user));

					XMLUtils.appendNewElement(generatorDocument, postElement, "formattedPostedDate", DateUtils.dateAndShortMonthToString(post.getPosted(), new Locale(systemInterface.getDefaultLanguage().getLanguageCode())) + " " + TimeUtils.TIME_FORMATTER.format(post.getPosted()));

					postsElement.appendChild(postElement);
				}

			}

			targetElement.appendChild(postsElement);
		}

	}

	private void appendAttachedFiles(Post post, Document doc, Element postElement, Map<Integer, FileArchiveModule> fileArchiveModules) {

		if (post.getLinkedFiles() != null) {

			FileArchiveModule fileArchiveModule = fileArchiveModules.get(post.getSectionID());

			if (fileArchiveModule != null) {

				try {

					XMLUtils.append(doc, postElement, "AttachedFiles", fileArchiveModule.getFiles(post.getLinkedFiles()));
					XMLUtils.appendNewElement(doc, postElement, "FileArchiveModuleAlias", fileArchiveModule.getFullAlias());
					
				} catch (SQLException e) {

					log.error("Unable to get attached files for post " + post, e);
				}

			}

		}

	}

	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = XMLUtils.createDomDocument();

		Element document = doc.createElement("Document");
		document.appendChild(RequestUtils.getRequestInfoAsXML(doc, req, uriParser));
		document.appendChild(this.moduleDescriptor.toXML(doc));
		document.appendChild(this.sectionInterface.getSectionDescriptor().toXML(doc));

		if (user != null) {
			document.appendChild(user.toXML(doc));
		}

		if (userProfileProvider != null) {
			XMLUtils.appendNewElement(doc, document, "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, document, "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		if (searchModule != null) {
			XMLUtils.appendNewElement(doc, document, "SearchModuleAlias", searchModule.getFullAlias());
		}

		XMLUtils.appendNewElement(doc, document, "serverURL", RequestUtils.getServerURL(req));

		doc.appendChild(document);

		return doc;
	}

}
