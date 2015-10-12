package se.sundsvall.collaborationroom.modules.link;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.link.bens.Link;
import se.sundsvall.collaborationroom.modules.link.bens.LinkURLRewriteBeanFilter;
import se.sundsvall.collaborationroom.modules.link.cruds.LinkCRUD;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.core.utils.crud.TransactionRequestFilter;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryParameter;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.url.URLRewriter;

public class LinkArchiveModule extends CBBaseModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Link load count", description = "The number of links to load when requesting getlinks method")
	private Integer linksLoadCount = 5;

	private LinkCRUD linkCRUD;

	private ConcurrentHashMap<Integer, Link> linkCacheMap;

	private CopyOnWriteArrayList<Link> linkCacheList;

	private QueryParameter<Link, Integer> sectionIDParameter;

	private AdvancedAnnotatedDAOWrapper<Link, Integer> linkDAO;
	
	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, LinkArchiveModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		linkDAO = daoFactory.getDAO(Link.class).getAdvancedWrapper(Integer.class);

		sectionIDParameter = linkDAO.getAnnotatedDAO().getParamFactory("sectionID", Integer.class).getParameter(getSectionID());

		linkDAO.getGetQuery().addParameter(sectionIDParameter);
		linkDAO.getGetAllQuery().addParameter(sectionIDParameter);

		linkCRUD = new LinkCRUD(linkDAO, this);
		linkCRUD.addRequestFilter(new TransactionRequestFilter(dataSource));
		linkCRUD.addBeanFilter(new LinkURLRewriteBeanFilter());

		cacheLinks();
	}

	protected void cacheLinks() throws SQLException {

		List<Link> links = linkDAO.getAll();

		if (links == null) {

			this.linkCacheList = new CopyOnWriteArrayList<Link>();
			this.linkCacheMap = new ConcurrentHashMap<Integer, Link>();

		} else {

			ConcurrentHashMap<Integer, Link> linkMap = new ConcurrentHashMap<Integer, Link>();

			for (Link link : links) {

				linkMap.put(link.getLinkID(), link);
			}

			Collections.sort(links);

			this.linkCacheList = new CopyOnWriteArrayList<Link>(links);
			this.linkCacheMap = linkMap;
		}
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return defaultMethod(req, res, user, uriParser, null);

	}

	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		log.info("User " + user + " listing links in section " + sectionInterface.getSectionDescriptor());
		
		Document doc = createDocument(req, uriParser, user);

		Element listElement = doc.createElement("ListLinks");

		doc.getFirstChild().appendChild(listElement);

		appendAllLinks(doc, listElement, req);

		if (validationErrors != null) {

			XMLUtils.append(doc, listElement, validationErrors);
			listElement.appendChild(RequestUtils.getRequestParameters(req, doc));

		}

		return new SimpleForegroundModuleResponse(doc, this.getDefaultBreadcrumb());

	}

	@WebPublic
	public ForegroundModuleResponse add(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return linkCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse update(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return linkCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse delete(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return linkCRUD.delete(req, res, user, uriParser);
	}

	@WebPublic(alias = "getlinks")
	public ForegroundModuleResponse loadAdditionalLinks(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer startIndex = uriParser.getInt(2);

		if (startIndex == null || uriParser.size() != 3) {

			throw new URINotFoundException(uriParser);
		}

		Document doc = createDocument(req, uriParser, user);
		Element listLinksElement = doc.createElement("LoadAdditionalLinks");
		doc.getFirstChild().appendChild(listLinksElement);

		appendLinks(startIndex, doc, listLinksElement, req);

		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		return moduleResponse;
	}

	public void appendLinks(int startIndex, Document doc, Element targetElement, HttpServletRequest req) {

		if (linkCacheList.isEmpty() || linkCacheList.size() <= startIndex) {

			return;
		}

		Element linksElement = doc.createElement("Links");

		int index = startIndex;

		while (linksElement.getChildNodes().getLength() < linksLoadCount && index < linkCacheList.size()) {

			Link link;

			try {

				link = linkCacheList.get(index);

			} catch (IndexOutOfBoundsException e) {

				// This is needed to properly handle concurrency where the list can shrink as we are iterating over it
				break;
			}

			Element linkElement = link.toXML(doc);
			XMLUtils.appendNewElement(doc, linkElement, "url", URLRewriter.setAbsoluteUrls(link.getUrl(), req));
			
			linksElement.appendChild(linkElement);

			index++;
		}

		targetElement.appendChild(linksElement);
	}
	
	public void appendAllLinks(Document doc, Element element, HttpServletRequest req) {
		
		for(Link link : linkCacheList) {
			
			Element linkElement = link.toXML(doc);
			
			XMLUtils.appendNewElement(doc, linkElement, "url", URLRewriter.setAbsoluteUrls(link.getUrl(), req));
			XMLUtils.appendNewElement(doc, linkElement, "formattedPostedDate", getFormattedDate(link.getPosted()));
			
			if(link.getUpdated() != null) {
				XMLUtils.appendNewElement(doc, linkElement, "formattedUpdatedDate", getFormattedDate(link.getUpdated()));
			}
			
			element.appendChild(linkElement);
			
		}
		
	}

	public synchronized void cacheLink(Integer linkID) {

		try {

			HighLevelQuery<Link> query = new HighLevelQuery<Link>();
			query.addParameter(linkDAO.getParameterFactory().getParameter(linkID));

			Link link = linkDAO.get(linkID);

			if (link != null) {

				List<Link> tempLinkList = new ArrayList<Link>(linkCacheList);

				linkCacheMap.put(linkID, link);
				tempLinkList.remove(link);
				tempLinkList.add(link);

				Collections.sort(tempLinkList);

				linkCacheList = new CopyOnWriteArrayList<Link>(tempLinkList);

			}

		} catch (SQLException e) {

			log.error("Unable to cache link with id " + linkID, e);
		}

	}

	public synchronized void deleteLink(Link link) {

		linkCacheMap.remove(link.getLinkID());
		linkCacheList.remove(link);

	}

	public Link getCachedLink(Integer linkID) {

		return linkCacheMap.get(linkID);
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

	public String getFormattedDate(Date date) {

		return DateUtils.dateAndShortMonthToString(date, new Locale(systemInterface.getDefaultLanguage().getLanguageCode())) + " " + TimeUtils.TIME_FORMATTER.format(date);

	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		if (CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "hasManageAccess", true);
		}

		return doc;
	}

}
