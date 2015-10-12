package se.sundsvall.collaborationroom.modules.filearchive.cruds;

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.filearchive.FileArchiveModule;
import se.sundsvall.collaborationroom.modules.filearchive.beans.Category;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.crud.BeanFilter;
import se.unlogic.hierarchy.core.utils.crud.IntegerBeanIDParser;
import se.unlogic.hierarchy.core.utils.crud.ModularCRUD;
import se.unlogic.standardutils.dao.CRUDDAO;
import se.unlogic.standardutils.dao.TransactionHandler;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;

public class CategoryCRUD extends ModularCRUD<Category, Integer, User, FileArchiveModule> {

	private static final AnnotatedRequestPopulator<Category> POPULATOR = new AnnotatedRequestPopulator<Category>(Category.class);

	public CategoryCRUD(CRUDDAO<Category, Integer> crudDAO, FileArchiveModule callback) {

		super(IntegerBeanIDParser.getInstance(), crudDAO, POPULATOR, "Category", "category", "", callback);
	}

	@Override
	protected Category populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Category category = super.populateFromAddRequest(req, user, uriParser);

		category.setSectionID(callback.getSectionID());

		return category;
	}

	@Override
	protected Category populateFromUpdateRequest(Category bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Category category = super.populateFromUpdateRequest(bean, req, user, uriParser);

		category.setSectionID(callback.getSectionID());

		return category;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(Category bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheCategory(bean.getCategoryID());

		callback.redirectToDefaultMethod(req, res, "category" + bean.getCategoryID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(Category bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheCategory(bean.getCategoryID());

		callback.redirectToDefaultMethod(req, res, "category" + bean.getCategoryID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(Category bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.deleteCategory(bean);

		callback.redirectToDefaultMethod(req, res);

		return null;
	}

	@Override
	protected void deleteFilteredBean(Category bean, HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		TransactionHandler transactionHandler = getTransactionHandler(req);

		if (transactionHandler != null) {

			crudDAO.delete(bean, transactionHandler);

			callback.deleteFileSystemFiles(bean);

			transactionHandler.commit();

		} else {

			crudDAO.delete(bean);
		}
	}

	@Override
	public ForegroundModuleResponse showAddForm(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToDefaultMethod(req, res, "addcategory");

			return null;
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());

	}

	@Override
	public ForegroundModuleResponse showUpdateForm(Category bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToDefaultMethod(req, res, "updatecategory" + bean.getCategoryID());

			return null;
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	public Category getRequestedBean(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, String getMode) throws SQLException, AccessDeniedException {

		if (getMode != null && getMode.equals(UPDATE) && NumberUtils.isInt(req.getParameter("categoryID"))) {

			Category category = getBean(Integer.valueOf(req.getParameter("categoryID")), getMode, req);

			if (category != null && beanFilters != null) {

				for (BeanFilter<? super Category> beanFilter : this.beanFilters) {

					beanFilter.beanLoaded(category, req, uriParser, user);
				}
			}

			return category;

		}

		return super.getRequestedBean(req, res, user, uriParser, getMode);
	}

	@Override
	public Category getBean(Integer beanID, String getMode, HttpServletRequest req) throws SQLException, AccessDeniedException {

		if (getMode != null && getMode.equals(DELETE)) {

			return callback.getCategory(beanID, true);
		}

		return super.getBean(beanID, getMode, req);
	}

	@Override
	protected void checkAddAccess(User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Add " + typeLogName + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkUpdateAccess(Category bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Update " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(Category bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Delete " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

}
