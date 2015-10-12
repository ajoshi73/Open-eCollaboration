package se.sundsvall.collaborationroom.modules.task.cruds;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.dosf.communitybase.events.CBSearchableItemDeleteEvent;
import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.task.TaskModule;
import se.sundsvall.collaborationroom.modules.task.beans.Task;
import se.sundsvall.collaborationroom.modules.task.beans.TaskList;
import se.sundsvall.collaborationroom.modules.utils.RequestOrURIParserBeanIDParser;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.standardutils.dao.AnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.populators.IntegerPopulator;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.webutils.http.BeanRequestPopulator;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.validation.ValidationUtils;

public class TaskCRUD extends CBBaseCRUD<Task, Integer, TaskModule> {

	private static final RequestOrURIParserBeanIDParser ID_PARSER = new RequestOrURIParserBeanIDParser("taskID");

	AnnotatedDAOWrapper<Task, Integer> crudDAO;

	public TaskCRUD(AnnotatedDAOWrapper<Task, Integer> crudDAO, BeanRequestPopulator<Task> populator, String typeElementName, String typeLogName, String listMethodAlias, TaskModule callback) {

		super(ID_PARSER, crudDAO, populator, typeElementName, typeLogName, listMethodAlias, callback);

		this.crudDAO = crudDAO;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(Task bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheTaskList(bean.getTaskList().getTaskListID());

		callback.taskAdded(bean, user);

		callback.redirectToMethod(req, res, "task" + bean.getTaskID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(Task bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cacheTaskList(bean.getTaskList().getTaskListID());

		if(req.getAttribute("oldTaskList") != null) {
			
			callback.cacheTaskList(((TaskList) req.getAttribute("oldTaskList")).getTaskListID());
		}
		
		callback.taskUpdated(bean, user, req);

		callback.redirectToMethod(req, res, "task" + bean.getTaskID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(Task bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(bean.getTaskID().toString(), callback.getModuleDescriptor()), EventTarget.ALL);

		callback.cacheTaskList(bean.getTaskList().getTaskListID());

		callback.taskDeleted(bean);

		callback.redirectToMethod(req, res, "tasklist" + bean.getTaskList().getTaskListID());

		return null;
	}

	@Override
	public ForegroundModuleResponse showAddForm(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToDefaultMethod(req, res);

			return null;
		}

		ForegroundModuleResponse moduleResponse = this.list(req, res, user, uriParser, null);

		if (validationException != null) {
			moduleResponse.getDocument().getFirstChild().appendChild(validationException.toXML(moduleResponse.getDocument()));
		}

		return moduleResponse;
	}

	@Override
	public ForegroundModuleResponse showUpdateForm(Task bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "task" + bean.getTaskID());

			return null;
		}

		if (uriParser.size() > 2) {

			return callback.getTaskListCRUD().showBean(callback.getCachedTaskList(bean.getTaskList().getTaskListID()), req, res, user, uriParser, validationException.getErrors());
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());

	}

	@Override
	public ForegroundModuleResponse list(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		if (validationErrors != null) {
			return callback.defaultMethod(req, res, user, uriParser, validationErrors);
		}

		return callback.defaultMethod(req, res, user, uriParser, null);
	}

	@Override
	protected Task populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Task task = super.populateFromAddRequest(req, user, uriParser);

		List<ValidationError> errors = new ArrayList<ValidationError>();

		populateRequest(task, req, user, uriParser, errors);

		if (!errors.isEmpty()) {

			throw new ValidationException(errors);
		}

		List<Task> tasks = task.getTaskList().getTasks();

		if (tasks != null) {

			task.setSortIndex(getNextSortIndex(tasks));

		} else {

			task.setSortIndex(0);
		}

		return task;
	}

	@Override
	protected Task populateFromUpdateRequest(Task bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		User responsibleUser = bean.getResponsibleUser();

		TaskList currentTaskList = bean.getTaskList();
		
		Task task = super.populateFromUpdateRequest(bean, req, user, uriParser);

		List<ValidationError> errors = new ArrayList<ValidationError>();

		populateRequest(task, req, user, uriParser, errors);

		if (!errors.isEmpty()) {

			throw new ValidationException(errors);
		}

		//If the task is not finished, check if the assigned user has changed, else don't bother since the task is already finished
		if (bean.getFinished() == null) {

			if ((responsibleUser == null && bean.getResponsibleUser() != null) || (responsibleUser != null && bean.getResponsibleUser() != null && !responsibleUser.equals(bean.getResponsibleUser()))) {

				req.setAttribute("responsibleUserChanged", true);
			}
		}
		
		if(!currentTaskList.equals(task.getTaskList())) {
			
			req.setAttribute("oldTaskList", currentTaskList);
		}

		return task;

	}

	protected Task populateRequest(Task task, HttpServletRequest req, User user, URIParser uriParser, List<ValidationError> errors) throws ValidationException, Exception {

		Integer taskListID = ValidationUtils.validateParameter("taskListID", req, true, IntegerPopulator.getPopulator(), errors);

		TaskList taskList = null;

		if (taskListID != null) {

			taskList = callback.getCachedTaskList(Integer.valueOf(taskListID));

			if (taskList == null) {

				errors.add(new ValidationError("TaskListNotFound"));

			} else {

				task.setTaskList(taskList);
			}

		}

		Integer responsibleUserID = ValidationUtils.validateParameter("responsibleUser", req, false, IntegerPopulator.getPopulator(), errors);

		if (responsibleUserID != null) {

			User responsibleUser = callback.getUserHandler().getUser(responsibleUserID, false, false);

			if (responsibleUser == null) {
				errors.add(new ValidationError("UserNotFound"));
			}

			task.setResponsibleUser(responsibleUser);

		} else {

			task.setResponsibleUser(null);

		}

		return task;

	}

	@Override
	public Task getBean(Integer beanID, String getMode, HttpServletRequest req) throws SQLException, AccessDeniedException {

		HighLevelQuery<Task> query = new HighLevelQuery<Task>(Task.TASKLIST_RELATION);

		query.addParameter(crudDAO.getParameterFactory().getParameter(beanID));

		return crudDAO.getAnnotatedDAO().get(query);
	}

	private Integer getNextSortIndex(List<Task> tasks) {

		for (int i = tasks.size() - 1; i >= 0; --i) {

			Integer sortIndex = tasks.get(i).getSortIndex();

			if (sortIndex != null) {

				return sortIndex + 1;
			}

		}

		return 0;
	}

	@Override
	protected void checkUpdateAccess(Task bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Update " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(Task bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Delete " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

}
