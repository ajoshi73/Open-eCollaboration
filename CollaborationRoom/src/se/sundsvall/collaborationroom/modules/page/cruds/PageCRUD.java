package se.sundsvall.collaborationroom.modules.page.cruds;

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.page.PageModule;
import se.sundsvall.collaborationroom.modules.page.beans.Page;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.crud.IntegerBeanIDParser;
import se.unlogic.standardutils.dao.CRUDDAO;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;

public class PageCRUD extends CBBaseCRUD<Page, Integer, PageModule> {

	private static final AnnotatedRequestPopulator<Page> POPULATOR = new AnnotatedRequestPopulator<Page>(Page.class);

	public PageCRUD(CRUDDAO<Page, Integer> crudDAO, PageModule callback) {

		super(IntegerBeanIDParser.getInstance(), crudDAO, POPULATOR, "Page", "page", "/", callback);
	}

	@Override
	protected void appendBean(Page page, Element targetElement, Document doc, User user) {

		Element postElement = page.toXML(doc);

		XMLUtils.appendNewElement(doc, postElement, "formattedPostedDate", callback.getFormattedDate(page.getPosted()));

		if (page.getUpdated() != null) {

			XMLUtils.appendNewElement(doc, postElement, "formattedUpdatedDate", callback.getFormattedDate(page.getUpdated()));
		}

		CBAccessUtils.appendBeanAccess(doc, targetElement, user, page, callback.getCBInterface().getRole(callback.getSectionID(), user));
		
		targetElement.appendChild(postElement);
	}

	@Override
	public ForegroundModuleResponse showUpdateForm(Page bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "/show/" + bean.getPageID());

			return null;
		}

		return showBean(bean, req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	protected Page populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Page page = super.populateFromAddRequest(req, user, uriParser);

		page.setSectionID(callback.getSectionID());

		return page;
	}

	@Override
	protected Page populateFromUpdateRequest(Page bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Page page = super.populateFromUpdateRequest(bean, req, user, uriParser);

		page.setSectionID(callback.getSectionID());

		return page;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(Page bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.pageAdded(bean);

		callback.redirectToMethod(req, res, "/show/" + bean.getPageID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(Page bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.pageUpdated(bean);

		callback.redirectToMethod(req, res, "/show/" + bean.getPageID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(Page bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.pageDeleted(bean);

		return super.filteredBeanDeleted(bean, req, res, user, uriParser);
	}
	
	@Override
	protected void checkAddAccess(User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {
		
		if(req.getMethod().equalsIgnoreCase("POST") && !CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))){
			
			throw new AccessDeniedException("Add " + typeLogName + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(Page page, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if(!CBAccessUtils.hasUpdateContentAccess(user, page, callback.getCBInterface().getRole(callback.getSectionID(), user))){
			
			throw new AccessDeniedException("Delete " + typeLogName + " " + page +  " denied in section " + callback.getSectionDescriptor());
		}
	}
	
}
