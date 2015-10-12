package se.sundsvall.collaborationroom.modules.link.cruds;

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.link.LinkArchiveModule;
import se.sundsvall.collaborationroom.modules.link.bens.Link;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.crud.BeanFilter;
import se.unlogic.hierarchy.core.utils.crud.IntegerBeanIDParser;
import se.unlogic.standardutils.dao.CRUDDAO;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.validation.ValidationErrorType;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.webutils.http.HTTPUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;

public class LinkCRUD extends CBBaseCRUD<Link, Integer, LinkArchiveModule> {

	private static final AnnotatedRequestPopulator<Link> POPULATOR = new AnnotatedRequestPopulator<Link>(Link.class);

	public LinkCRUD(CRUDDAO<Link, Integer> crudDAO, LinkArchiveModule callback) {

		super(IntegerBeanIDParser.getInstance(), crudDAO, POPULATOR, "Link", "link", "", callback);
	}

	@Override
	protected Link populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Link link = super.populateFromAddRequest(req, user, uriParser);

		validateLinkURL(link);

		link.setSectionID(callback.getSectionID());
		link.setPoster(user);
		link.setPosted(TimeUtils.getCurrentTimestamp());

		return link;
	}

	@Override
	protected Link populateFromUpdateRequest(Link bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Link link = super.populateFromUpdateRequest(bean, req, user, uriParser);

		validateLinkURL(link);

		link.setSectionID(callback.getSectionID());
		link.setEditor(user);
		link.setUpdated(TimeUtils.getCurrentTimestamp());

		return link;
	}

	protected void validateLinkURL(Link bean) throws ValidationException {

		if (!HTTPUtils.isValidURL(bean.getUrl())) {

			throw new ValidationException(new ValidationError("url", ValidationErrorType.InvalidFormat));
		}
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(Link bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheLink(bean.getLinkID());

		callback.redirectToDefaultMethod(req, res, "link" + bean.getLinkID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(Link bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheLink(bean.getLinkID());

		callback.redirectToDefaultMethod(req, res, "link" + bean.getLinkID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(Link bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.deleteLink(bean);

		callback.redirectToDefaultMethod(req, res);

		return null;
	}

	@Override
	public ForegroundModuleResponse showAddForm(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToDefaultMethod(req, res, "add");

			return null;
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());

	}

	@Override
	public ForegroundModuleResponse showUpdateForm(Link bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToDefaultMethod(req, res, "update" + bean.getLinkID());

			return null;
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	public Link getRequestedBean(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, String getMode) throws SQLException, AccessDeniedException {

		if (getMode != null && getMode.equals(UPDATE) && NumberUtils.isInt(req.getParameter("linkID"))) {

			Link link = getBean(Integer.valueOf(req.getParameter("linkID")), getMode, req);

			if (link != null && beanFilters != null) {

				for (BeanFilter<? super Link> beanFilter : this.beanFilters) {

					beanFilter.beanLoaded(link, req, uriParser, user);
				}
			}

			return link;

		}

		return super.getRequestedBean(req, res, user, uriParser, getMode);
	}

	@Override
	protected void checkUpdateAccess(Link bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Update " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(Link bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Delete " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

}
