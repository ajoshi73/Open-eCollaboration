package se.sundsvall.collaborationroom.modules.task.cruds;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.task.TaskModule;
import se.sundsvall.collaborationroom.modules.task.beans.TaskList;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.crud.BeanFilter;
import se.unlogic.hierarchy.core.utils.crud.IntegerBeanIDParser;
import se.unlogic.standardutils.dao.CRUDDAO;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.BeanRequestPopulator;
import se.unlogic.webutils.http.URIParser;

public class TaskListCRUD extends CBBaseCRUD<TaskList, Integer, TaskModule> {

	public TaskListCRUD(CRUDDAO<TaskList, Integer> crudDAO, BeanRequestPopulator<TaskList> populator, String typeElementName, String typeLogName, String listMethodAlias, TaskModule callback) {

		super(IntegerBeanIDParser.getInstance(), crudDAO, populator, typeElementName, typeLogName, listMethodAlias, callback);

	}

	@Override
	protected TaskList populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		TaskList taskList = super.populateFromAddRequest(req, user, uriParser);

		taskList.setSectionID(callback.getSectionID());

		return taskList;
	}

	@Override
	protected TaskList populateFromUpdateRequest(TaskList bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		TaskList taskList = super.populateFromUpdateRequest(bean, req, user, uriParser);

		taskList.setSectionID(callback.getSectionID());

		return taskList;
	}

	@Override
	public TaskList getBean(Integer beanID, String getMode, HttpServletRequest req) throws SQLException, AccessDeniedException {

		if (getMode != null && getMode == SHOW) {

			return callback.getCachedTaskList(beanID);
		}

		return super.getBean(beanID, getMode, req);
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(TaskList bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheTaskList(bean.getTaskListID());

		callback.redirectToMethod(req, res, "tasklist" + bean.getTaskListID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(TaskList bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheTaskList(bean.getTaskListID());

		callback.redirectToMethod(req, res, "tasklist" + bean.getTaskListID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(TaskList bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.deleteTaskList(bean);

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
	public ForegroundModuleResponse showUpdateForm(TaskList bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "/showtasklist/" + bean.getTaskListID());

			return null;
		}

		if(uriParser.size() > 2) {

			return showBean(callback.getCachedTaskList(bean.getTaskListID()), req, res, user, uriParser, validationException.getErrors());
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	protected void appendShowFormData(TaskList bean, Document doc, Element showTypeElement, User user, HttpServletRequest req, HttpServletResponse res, URIParser uriParser) throws SQLException, IOException, Exception {

		callback.appendAllMembers(doc, showTypeElement);
		
		XMLUtils.append(doc, showTypeElement, "TaskLists", callback.getCachedTaskLists());
	}

	@Override
	public TaskList getRequestedBean(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, String getMode) throws SQLException, AccessDeniedException {

		if (getMode != null && getMode.equals(UPDATE) && NumberUtils.isInt(req.getParameter("taskListID"))) {

			TaskList taskList = getBean(Integer.valueOf(req.getParameter("taskListID")), getMode, req);

			if (taskList != null && beanFilters != null) {

				for (BeanFilter<? super TaskList> beanFilter : this.beanFilters) {

					beanFilter.beanLoaded(taskList, req, uriParser, user);
				}
			}

			return taskList;

		}

		return super.getRequestedBean(req, res, user, uriParser, getMode);
	}

	@Override
	protected void checkUpdateAccess(TaskList bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if(!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))){

			throw new AccessDeniedException("Update " + typeLogName + " " + bean +  " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(TaskList bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if(!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))){

			throw new AccessDeniedException("Delete " + typeLogName + " " + bean +  " denied in section " + callback.getSectionDescriptor());
		}
	}

}
