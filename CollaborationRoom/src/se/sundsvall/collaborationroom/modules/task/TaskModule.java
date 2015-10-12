package se.sundsvall.collaborationroom.modules.task;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
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
import se.dosf.communitybase.events.CBMemberRemovedEvent;
import se.dosf.communitybase.events.CBSearchableItemDeleteEvent;
import se.dosf.communitybase.events.CBSearchableItemUpdateEvent;
import se.dosf.communitybase.interfaces.CBSearchable;
import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.dosf.communitybase.interfaces.EventTransformer;
import se.dosf.communitybase.interfaces.Notification;
import se.dosf.communitybase.interfaces.NotificationHandler;
import se.dosf.communitybase.interfaces.NotificationTransformer;
import se.dosf.communitybase.interfaces.SectionEventProvider;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.sundsvall.collaborationroom.modules.task.beans.Task;
import se.sundsvall.collaborationroom.modules.task.beans.TaskElementableListener;
import se.sundsvall.collaborationroom.modules.task.beans.TaskList;
import se.sundsvall.collaborationroom.modules.task.beans.TaskSearchableItem;
import se.sundsvall.collaborationroom.modules.task.cruds.TaskCRUD;
import se.sundsvall.collaborationroom.modules.task.cruds.TaskListCRUD;
import se.sundsvall.collaborationroom.modules.utils.comparators.PostedComparator;
import se.unlogic.hierarchy.core.annotations.EventListener;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.annotations.XSLVariable;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.SimpleSectionDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventSource;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.handlers.UserHandler;
import se.unlogic.hierarchy.core.interfaces.EventHandler;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.crud.TransactionRequestFilter;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.AnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.LowLevelQuery;
import se.unlogic.standardutils.dao.QueryParameter;
import se.unlogic.standardutils.dao.RelationQuery;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.json.JsonObject;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.xml.XMLGeneratorDocument;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.HTTPUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;

public class TaskModule extends CBBaseModule implements CBSearchable, SectionEventProvider, NotificationTransformer, EventTransformer<Task>, ShortCutProvider {

	public static final String TASK_ADDED_EVENT_TYPE = "added";
	public static final String TASK_FINISHED_EVENT_TYPE = "finished";

	private static final AnnotatedRequestPopulator<TaskList> TASKLIST_POPULATOR = new AnnotatedRequestPopulator<TaskList>(TaskList.class);
	private static final AnnotatedRequestPopulator<Task> TASK_POPULATOR = new AnnotatedRequestPopulator<Task>(Task.class);

	private static final PostedComparator POSTED_COMPARATOR = new PostedComparator();
	private static final FinishedComparator FINISHED_COMPARATOR = new FinishedComparator();

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Deadline treshold (days)", description = "The number of days before a task is being marked as 'is about to miss deadline'", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private int deadlineThreshold = 3;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Tasks load count", description = "The number of tasks to return when calling getTasks method", required = true)
	private Integer taskLoadCount = 5;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Event stylesheet", description = "The stylesheet used to transform events")
	private String eventStylesheet = "TaskEvent.sv.xsl";

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Notification stylesheet", description = "The stylesheet used to transform notifications")
	private String notificationStylesheet = "TaskNotification.sv.xsl";

	@XSLVariable(prefix = "java.")
	private String shortCutText = "Add task";

	private ConcurrentHashMap<Integer, TaskList> taskListMap;

	private CopyOnWriteArrayList<TaskList> finishedTaskListCache;

	private CopyOnWriteArrayList<TaskList> activeTaskListCache;

	private AdvancedAnnotatedDAOWrapper<TaskList, Integer> taskListDAO;

	private AnnotatedDAO<Task> taskDAO;

	private QueryParameter<TaskList, Integer> taskListSectionIDParameter;

	private TaskListCRUD taskListCRUD;

	private TaskCRUD taskCRUD;

	@InstanceManagerDependency(required = false)
	protected UserProfileProvider userProfileProvider;

	@InstanceManagerDependency(required = false)
	protected NotificationHandler notificationHandler;

	private SimpleViewFragmentTransformer eventFragmentTransformer;

	private SimpleViewFragmentTransformer notificationFragmentTransformer;

	private Integer sourceModuleID;

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

	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, TaskModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		taskListDAO = daoFactory.getDAO(TaskList.class).getAdvancedWrapper(Integer.class);
		taskDAO = daoFactory.getDAO(Task.class);

		taskListSectionIDParameter = taskListDAO.getAnnotatedDAO().getParamFactory("sectionID", Integer.class).getParameter(getSectionID());

		taskListDAO.getGetQuery().addParameter(taskListSectionIDParameter);
		taskListDAO.getGetAllQuery().addParameter(taskListSectionIDParameter);

		taskListCRUD = new TaskListCRUD(taskListDAO, TASKLIST_POPULATOR, "TaskList", "tasklist", "/", this);
		taskListCRUD.addRequestFilter(new TransactionRequestFilter(dataSource));

		AnnotatedDAOWrapper<Task, Integer> taskDAO = daoFactory.getDAO(Task.class).getWrapper(Integer.class);

		taskCRUD = new TaskCRUD(taskDAO, TASK_POPULATOR, "Task", "task", "/", this);
		taskListCRUD.addRequestFilter(new TransactionRequestFilter(dataSource));

		cacheTaskLists();
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return defaultMethod(req, res, user, uriParser, null);

	}

	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		log.info("User " + user + " listing tasks in section " + sectionInterface.getSectionDescriptor());

		Document doc = createDocument(req, uriParser, user);

		Element listElement = doc.createElement("ListTaskLists");

		doc.getFirstChild().appendChild(listElement);

		XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

		TaskElementableListener elementableListener = new TaskElementableListener(deadlineThreshold);

		generatorDocument.addElementableListener(Task.class, elementableListener);

		Element activeElement = doc.createElement("ActiveTaskLists");

		listElement.appendChild(activeElement);

		for (TaskList taskList : activeTaskListCache) {

			activeElement.appendChild(taskList.toXML(generatorDocument));
		}

		if (req.getParameter("withFinished") != null) {

			for (TaskList taskList : finishedTaskListCache) {

				activeElement.appendChild(taskList.toXML(generatorDocument));
			}

			XMLUtils.appendNewElement(generatorDocument, listElement, "WithFinished");
		}
		
		if (req.getParameter("taskListFilter") != null) {

			XMLUtils.appendNewElement(generatorDocument, listElement, "TaskListFilter", req.getParameter("taskListFilter"));
		}
		
		if (req.getParameter("membersFilter") != null) {

			XMLUtils.appendNewElement(generatorDocument, listElement, "MembersFilter", req.getParameter("membersFilter"));
		}
		
		if (req.getParameter("stateFilter") != null) {

			XMLUtils.appendNewElement(generatorDocument, listElement, "StateFilter", req.getParameter("stateFilter"));
		}
		
		if (req.getParameter("tableSelected") != null) {
			XMLUtils.appendNewElement(generatorDocument, listElement, "TableSelected");
		}

		generatorDocument.addIgnoredField(TaskList.TASKS_RELATION);

		Element finishedElement = doc.createElement("FinishedTaskLists");

		for (TaskList taskList : finishedTaskListCache) {

			finishedElement.appendChild(taskList.toXML(generatorDocument));
		}

		listElement.appendChild(finishedElement);

		appendAllMembers(generatorDocument, listElement);

		XMLUtils.append(generatorDocument, listElement, "TaskLists", taskListMap.values());

		if (validationErrors != null) {

			XMLUtils.append(generatorDocument, listElement, validationErrors);
			listElement.appendChild(RequestUtils.getRequestParameters(req, generatorDocument));

		}

		return new SimpleForegroundModuleResponse(doc, this.getDefaultBreadcrumb());

	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		if (hasManageAccess(user)) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "hasManageAccess", true);
		}

		return doc;
	}

	public boolean hasManageAccess(User user) {

		if (CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {

			return true;
		}

		return false;
	}

	public boolean checkManageAccess(User user) throws AccessDeniedException {

		if (!hasManageAccess(user)) {

			throw new AccessDeniedException("Manage tasks access denied");
		}

		return false;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addTaskList(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskListCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateTaskList(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskListCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteTaskList(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskListCRUD.delete(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse showTaskList(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskListCRUD.show(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addTask(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskCRUD.add(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateTask(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskCRUD.update(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteTask(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return taskCRUD.delete(req, res, user, uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse toggleTask(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		Task task = taskCRUD.getRequestedBean(req, res, user, uriParser, null);

		if (task != null) {

			if (task.getResponsibleUser() != null && !task.getResponsibleUser().equals(user)) {

				throw new AccessDeniedException("Toggle task access denied");
			}

			boolean finished;

			if (task.getFinished() == null) {

				task.setFinished(TimeUtils.getCurrentTimestamp());
				task.setFinishedByUser(user);
				task.setSortIndex(null);

				finished = true;

			} else {

				task.setFinished(null);
				task.setFinishedByUser(null);

				finished = false;

			}

			taskCRUD.getCrudDAO().update(task);

			cacheTaskList(task.getTaskList().getTaskListID());

			JsonObject response = new JsonObject();

			if (finished) {

				response.putField("finished", DateUtils.DATE_TIME_FORMATTER.format(task.getFinished()));
				response.putField("finishedBy", user.getFirstname() + " " + user.getLastname());

			}

			HTTPUtils.sendReponse(response.toJson(), "application/json", res);

			if (sectionEventHandler != null) {

				SectionEvent finishedEvent = getFinishedEvent(task);

				//Delete previous event
				sectionEventHandler.removeEvent(moduleDescriptor.getSectionID(), finishedEvent);

				if (task.getFinished() != null) {

					//Add new event
					sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), finishedEvent);
				}
			}

			return null;
		}

		throw new URINotFoundException(uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse sortTaskList(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		checkManageAccess(user);

		Integer taskListID = uriParser.getInt(2);

		if (uriParser.size() > 2 && taskListID != null) {

			HighLevelQuery<TaskList> query = new HighLevelQuery<TaskList>(TaskList.TASKS_RELATION);

			query.addParameter(taskListDAO.getParameterFactory().getParameter(taskListID));

			TaskList taskList = taskListDAO.getAnnotatedDAO().get(query);

			if (taskList != null) {

				List<Task> tasks = taskList.getTasks();

				if (tasks != null) {

					for (Task task : tasks) {

						if (task.getFinished() == null) {

							Integer sortIndex = NumberUtils.toInt(req.getParameter("task_" + task.getTaskID()));

							task.setSortIndex(sortIndex);

						} else {

							task.setSortIndex(null);

						}

					}

					taskListDAO.getAnnotatedDAO().update(taskList, new RelationQuery(TaskList.TASKS_RELATION));

					cacheTaskList(taskList.getTaskListID());

					JsonObject response = new JsonObject();

					response.putField("sorted", true);

					HTTPUtils.sendReponse(response.toJson(), "application/json", res);

					return null;

				}

			}

		}

		throw new URINotFoundException(uriParser);
	}

	@WebPublic(alias = "gettasks")
	public ForegroundModuleResponse loadAdditionalTasks(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer startIndex = uriParser.getInt(2);

		if (startIndex == null || uriParser.size() != 3) {

			throw new URINotFoundException(uriParser);
		}

		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("LoadAdditionalTasks");
		doc.getFirstChild().appendChild(listPostsElement);

		appendAdditionalTasks(doc, listPostsElement, startIndex);

		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		return moduleResponse;
	}

	public void appendAdditionalTasks(Document doc, Element element, int startIndex) throws SQLException {

		TaskElementableListener elementableListener = new TaskElementableListener(deadlineThreshold);

		List<Task> tasks = this.getActiveTasks(startIndex, taskLoadCount, true);

		if (tasks != null) {

			for (Task task : tasks) {

				Element taskElement = task.toXML(doc);

				elementableListener.elementGenerated(doc, taskElement, task);

				element.appendChild(taskElement);
			}

		}

	}

	protected void cacheTaskLists() throws SQLException {

		log.info("Caching task lists");

		taskListMap = new ConcurrentHashMap<Integer, TaskList>();

		finishedTaskListCache = new CopyOnWriteArrayList<TaskList>();

		activeTaskListCache = new CopyOnWriteArrayList<TaskList>();

		HighLevelQuery<TaskList> query = new HighLevelQuery<TaskList>(TaskList.TASKS_RELATION);

		query.addParameter(taskListSectionIDParameter);

		List<TaskList> taskLists = taskListDAO.getAnnotatedDAO().getAll(query);

		if (taskLists == null) {

			taskListMap = new ConcurrentHashMap<Integer, TaskList>();
			finishedTaskListCache = new CopyOnWriteArrayList<TaskList>();
			activeTaskListCache = new CopyOnWriteArrayList<TaskList>();

		} else {

			ConcurrentHashMap<Integer, TaskList> taskListTempMap = new ConcurrentHashMap<Integer, TaskList>();
			List<TaskList> activeTempTaskList = new ArrayList<TaskList>();
			List<TaskList> finishedTempTaskList = new ArrayList<TaskList>();

			for (TaskList taskList : taskLists) {

				List<Task> tasks = taskList.getTasks();

				boolean finished = false;

				if (tasks != null) {

					finished = true;

					for (Task task : tasks) {

						if (task.getFinished() == null) {
							finished = false;
							break;
						}

					}

					Collections.sort(tasks);

				}

				if (finished) {

					finishedTempTaskList.add(taskList);

				} else {

					activeTempTaskList.add(taskList);

				}

				taskListTempMap.put(taskList.getTaskListID(), taskList);

			}

			Collections.sort(finishedTempTaskList);
			Collections.sort(activeTempTaskList);

			taskListMap = taskListTempMap;
			finishedTaskListCache = new CopyOnWriteArrayList<TaskList>(finishedTempTaskList);
			activeTaskListCache = new CopyOnWriteArrayList<TaskList>(activeTempTaskList);

			log.info("Chached " + taskListMap.size() + " task lists");

		}

	}

	public synchronized void cacheTaskList(Integer taskListID) {

		try {

			HighLevelQuery<TaskList> query = new HighLevelQuery<TaskList>(TaskList.TASKS_RELATION);
			query.addParameter(taskListDAO.getParameterFactory().getParameter(taskListID));

			TaskList taskList = taskListDAO.getAnnotatedDAO().get(query);

			if (taskList != null) {

				List<Task> tasks = taskList.getTasks();

				List<TaskList> tempActiveTaskLists = new ArrayList<TaskList>(activeTaskListCache);
				List<TaskList> tempFinishedTaskLists = new ArrayList<TaskList>(finishedTaskListCache);

				boolean finished = false;

				if (tasks != null) {

					finished = true;

					for (Task task : tasks) {

						if (task.getFinished() == null) {
							finished = false;
							break;
						}

					}

					Collections.sort(tasks);

				}

				taskListMap.put(taskList.getTaskListID(), taskList);

				if (finished) {

					tempActiveTaskLists.remove(taskList);
					tempFinishedTaskLists.remove(taskList);
					tempFinishedTaskLists.add(taskList);

					Collections.sort(tempFinishedTaskLists);

				} else {

					tempFinishedTaskLists.remove(taskList);
					tempActiveTaskLists.remove(taskList);
					tempActiveTaskLists.add(taskList);

					Collections.sort(tempActiveTaskLists);

				}

				finishedTaskListCache = new CopyOnWriteArrayList<TaskList>(tempFinishedTaskLists);
				activeTaskListCache = new CopyOnWriteArrayList<TaskList>(tempActiveTaskLists);

				List<CBSearchableItem> searchableItems = getSearchableItems(taskList);

				if (searchableItems != null) {

					systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemUpdateEvent(searchableItems, moduleDescriptor), EventTarget.ALL);
				}
			}

		} catch (SQLException e) {

			log.error("Unable to cache tasklist with id " + taskListID, e);
		}

	}

	public synchronized void deleteTaskList(TaskList taskList) {

		TaskList cachedTaskList = taskListMap.get(taskList.getTaskListID());

		if (cachedTaskList != null && cachedTaskList.getTasks() != null) {

			for (Task task : cachedTaskList.getTasks()) {

				systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(task.getTaskID().toString(), moduleDescriptor), EventTarget.ALL);
			}
		}

		taskListMap.remove(taskList.getTaskListID());
		finishedTaskListCache.remove(taskList);
		activeTaskListCache.remove(taskList);

		if (notificationHandler != null && sourceModuleID != null) {

			try {
				//Delete any notifications for this tasklist
				notificationHandler.deleteNotifications(moduleDescriptor.getSectionID(), sourceModuleID, taskList.getTaskListID(), null);

			} catch (Exception e) {

				log.error("Error deleting notifications for task list " + taskList, e);
			}
		}

		if (sectionEventHandler != null) {

			sectionEventHandler.filterEvents(moduleDescriptor.getSectionID(), moduleDescriptor.getModuleID(), new TaskListEventFilter(taskList));
		}
	}

	public TaskList getCachedTaskList(Integer taskListID) {

		return taskListMap.get(taskListID);
	}

	public Collection<TaskList> getCachedActiveTaskLists() {

		return activeTaskListCache;
	}

	public Collection<TaskList> getCachedTaskLists() {

		return taskListMap.values();
	}

	public List<Task> getActiveTasks(int startIndex, int taskLoadCount, boolean addRelations) throws SQLException {

		LowLevelQuery<Task> query = new LowLevelQuery<Task>();

		query.setSql("SELECT * FROM " + taskDAO.getTableName() + " AS t "
				+ "LEFT JOIN " + taskListDAO.getAnnotatedDAO().getTableName() + " AS tl ON(t.taskListID = tl.taskListID) "
				+ "WHERE tl.sectionID = ? AND t.finished IS NULL ORDER BY CASE WHEN t.deadLine IS NULL THEN 1 ELSE 0 END, t.deadLine LIMIT ?, ?");

		query.addParameter(getSectionID());
		query.addParameter(startIndex);
		query.addParameter(taskLoadCount);

		if (addRelations) {
			query.addRelation(Task.TASKLIST_RELATION);
		}

		return taskDAO.getAll(query);
	}

	public UserHandler getUserHandler() {

		return systemInterface.getUserHandler();
	}

	public void appendAllMembers(Document doc, Element element) {

		List<Integer> userIDs = cbInterface.getSectionMembers(getSectionID());

		if (!CollectionUtils.isEmpty(userIDs)) {
			XMLUtils.append(doc, element, "members", systemInterface.getUserHandler().getUsers(userIDs, false, false));
		}

	}

	@Override
	public void redirectToMethod(HttpServletRequest req, HttpServletResponse res, String anchor) throws IOException {

		String redirectURI = (String) req.getAttribute("redirectURI");

		if (StringUtils.isEmpty(redirectURI)) { //Used in MyTasks
			redirectURI = (String) req.getParameter("redirectURI");
		}

		if (redirectURI != null) {

			res.sendRedirect(req.getContextPath() + redirectURI + "#" + anchor);

		} else {
			
			StringBuilder extra = new StringBuilder();
			String taskListFilter = req.getParameter("taskListFilter");
			String membersFilter = req.getParameter("membersFilter");
			String stateFilter = req.getParameter("stateFilter");
			String withFinished = req.getParameter("withFinished");
			
			if(req.getParameter("tableSelected") != null){
				extra.append("tableSelected");
			}

			if (taskListFilter != null) {
				if(extra.length() > 0){
					extra.append('&');
				}

				extra.append("taskListFilter=");
				extra.append(taskListFilter);
			}

			if (membersFilter != null) {
				extra.append("&membersFilter=");
				extra.append(membersFilter);
			}

			if (stateFilter != null) {
				extra.append("&stateFilter=");
				extra.append(stateFilter);
			}
			
			if (withFinished != null) {
				extra.append("&withFinished");
			}

			if(extra.length() > 0){
			
				res.sendRedirect(this.getModuleURI(req) + "?" + extra + "#" + anchor);

			} else {
				
				this.redirectToDefaultMethod(req, res, anchor);
			}
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

	public int getDeadlineThreshold() {

		return deadlineThreshold;
	}

	public TaskListCRUD getTaskListCRUD() {

		return taskListCRUD;
	}

	public Integer getTaskLoadCount() {

		return taskLoadCount;
	}

	@Override
	public List<? extends CBSearchableItem> getSearchableItems() throws Exception {

		if (!this.taskListMap.isEmpty()) {

			List<CBSearchableItem> searchableItems = new ArrayList<CBSearchableItem>(taskListMap.size() * 10);

			for (TaskList taskList : this.taskListMap.values()) {

				List<CBSearchableItem> listItems = getSearchableItems(taskList);

				if (listItems != null) {

					searchableItems.addAll(listItems);
				}
			}

			return searchableItems;
		}

		return null;
	}

	private List<CBSearchableItem> getSearchableItems(TaskList taskList) {

		if (taskList.getTasks() != null) {

			List<CBSearchableItem> listItems = new ArrayList<CBSearchableItem>(taskList.getTasks().size());

			for (Task task : taskList.getTasks()) {

				listItems.add(getSearchableItem(task, taskList));
			}

			return listItems;
		}

		return null;
	}

	private CBSearchableItem getSearchableItem(Task task, TaskList taskList) {

		return new TaskSearchableItem(task, taskList.getName(), "/" + moduleDescriptor.getAlias() + "/showtasklist/" + taskList.getTaskListID() + "#task" + task.getTaskID());
	}

	public EventHandler getEventHandler() {

		return systemInterface.getEventHandler();
	}

	public ForegroundModuleDescriptor getModuleDescriptor() {

		return moduleDescriptor;
	}

	public void taskAdded(Task bean, User user) throws SQLException {

		//If there is a responsible user create a notification
		if (bean.getResponsibleUser() != null && !bean.getResponsibleUser().equals(user)) {

			addNotification(bean);
		}

		if (sectionEventHandler != null) {

			sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getPostedEvent(bean));
		}
	}

	public void taskUpdated(Task bean, User user, HttpServletRequest req) throws SQLException {

		if (req.getAttribute("responsibleUserChanged") != null && bean.getResponsibleUser() != null && !bean.getResponsibleUser().equals(user)) {

			addNotification(bean);
		}

		if (sectionEventHandler != null) {

			SectionEvent postedEvent = getPostedEvent(bean);
			SectionEvent finishedEvent = getFinishedEvent(bean);

			//Replace add event
			sectionEventHandler.replaceEvent(moduleDescriptor.getSectionID(), postedEvent);

			//Delete or replace finished event
			if (bean.getFinished() != null) {

				sectionEventHandler.replaceEvent(moduleDescriptor.getSectionID(), finishedEvent);
			} else {

				sectionEventHandler.removeEvent(moduleDescriptor.getSectionID(), finishedEvent);
			}
		}
	}

	public void taskDeleted(Task bean) {

		if (notificationHandler != null && sourceModuleID != null) {

			try {
				//Delete any notifications for this task
				notificationHandler.deleteNotifications(moduleDescriptor.getSectionID(), sourceModuleID, bean.getTaskList().getTaskListID(), bean.getTaskID().toString());

			} catch (SQLException e) {

				log.error("Error deleting notifications for task " + bean, e);
			}
		}

		if (sectionEventHandler != null) {

			sectionEventHandler.filterEvents(moduleDescriptor.getSectionID(), moduleDescriptor.getModuleID(), new TaskEventFilter(bean));
		}
	}

	private void addNotification(Task bean) {

		if (notificationHandler != null && sourceModuleID != null) {

			try {
				//Add a new notification using the task ID as notification type since this module only produces one type of notifications
				notificationHandler.addNotification(bean.getResponsibleUser().getUserID(), moduleDescriptor.getSectionID(), sourceModuleID, bean.getTaskID().toString(), bean.getTaskList().getTaskListID(), null);
			} catch (SQLException e) {

				log.error("Error adding notification for task " + bean, e);
			}
		}
	}

	@Override
	public ViewFragment getFragment(Task task, EventFormat format, String fullContextPath, String eventType) throws Exception {

		ViewFragmentTransformer transformer = this.eventFragmentTransformer;

		if (transformer == null) {

			log.warn("No event fragment transformer available, unable to transform event for task " + task);
			return null;
		}

		if (log.isDebugEnabled()) {

			log.debug("Transforming event for task " + task);
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "TaskURL", fullContextPath + this.getFullAlias() + "/showtasklist/" + task.getTaskListID() + "#task" + task.getTaskID());

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		XMLUtils.appendNewElement(doc, documentElement, "EventType", eventType);
		documentElement.appendChild(task.toXML(doc));

		return transformer.createViewFragment(doc);
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

		Integer taskID = NumberUtils.toInt(notification.getNotificationType());

		if (taskID == null) {

			log.warn("Unable to parse task ID in notification " + notification);
			return null;
		}

		Task task = taskCRUD.getBean(taskID, TaskCRUD.SHOW, null);

		if (task == null) {

			log.warn("Unable to find task with ID " + task + " skipping notification " + notification);
			return null;
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);

		documentElement.appendChild(task.toXML(doc));

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "SectionName", sectionInterface.getSectionDescriptor().getName());
		XMLUtils.appendNewElement(doc, documentElement, "ModuleName", moduleDescriptor.getName());

		XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);
		XMLUtils.appendNewElement(doc, documentElement, "TaskURL", fullContextPath + this.getFullAlias() + "/showtasklist/" + task.getTaskList().getTaskListID() + "#task" + task.getTaskID());

		if (!notification.isRead()) {

			XMLUtils.appendNewElement(doc, documentElement, "Unread");
		}

		return transformer.createViewFragment(doc);
	}

	@Override
	public List<SectionEvent> getEvents(Timestamp breakpoint, int count) throws Exception {

		List<TaskList> taskLists = new ArrayList<TaskList>(taskListMap.values());

		if (taskLists.isEmpty()) {

			return null;
		}

		List<Task> postedTasks = new ArrayList<Task>();
		List<Task> finishedTasks = new ArrayList<Task>();

		for (TaskList taskList : taskLists) {

			if (taskList.getTasks() == null) {

				continue;
			}

			if (breakpoint != null) {

				for (Task task : taskList.getTasks()) {

					if (task.getPosted().after(breakpoint)) {

						checkTaskListID(task, taskList);

						postedTasks.add(task);
					}

					if (task.getFinished() != null && task.getFinished().after(breakpoint)) {

						checkTaskListID(task, taskList);

						finishedTasks.add(task);
					}
				}

			} else {

				for (Task task : taskList.getTasks()) {

					checkTaskListID(task, taskList);

					postedTasks.add(task);

					if (task.getFinished() != null) {

						finishedTasks.add(task);
					}
				}
			}
		}

		if (postedTasks.isEmpty() && finishedTasks.isEmpty()) {

			return null;
		}

		List<SectionEvent> events = new ArrayList<SectionEvent>(NumberUtils.getLowestValue(postedTasks.size() + finishedTasks.size(), count));

		if (!postedTasks.isEmpty()) {

			if (postedTasks.size() > count) {

				Collections.sort(postedTasks, POSTED_COMPARATOR);

				postedTasks = postedTasks.subList(0, count);
			}

			for (Task task : postedTasks) {

				events.add(getPostedEvent(task));
			}
		}

		if (!finishedTasks.isEmpty()) {

			if (finishedTasks.size() > count) {

				Collections.sort(finishedTasks, FINISHED_COMPARATOR);

				finishedTasks = finishedTasks.subList(0, count);
			}

			for (Task task : finishedTasks) {

				events.add(getFinishedEvent(task));
			}
		}

		return events;
	}

	private void checkTaskListID(Task task, TaskList taskList) {

		if (task.getTaskListID() == null) {

			task.setTaskListID(taskList.getTaskListID());
		}
	}

	private SectionEvent getFinishedEvent(Task task) {

		return new TransformedSectionEvent<Task>(moduleDescriptor.getModuleID(), task.getFinished(), task, this, TASK_FINISHED_EVENT_TYPE);
	}

	private SectionEvent getPostedEvent(Task task) {

		return new TransformedSectionEvent<Task>(moduleDescriptor.getModuleID(), task.getPosted(), task, this, TASK_ADDED_EVENT_TYPE);
	}

	@Override
	public List<ShortCut> getShortCuts(User user) {

		if (hasManageAccess(user)) {

			return Collections.singletonList(new ShortCut(shortCutText, shortCutText, this.getFullAlias() + "#add"));

		}

		return null;
	}

	@EventListener(channel = SimpleSectionDescriptor.class)
	public void processEvent(CBMemberRemovedEvent event, EventSource source) {

		if (event.getSectionID().equals(this.getSectionID())) {

			LowLevelQuery<Task> query = new LowLevelQuery<Task>("UPDATE " + taskDAO.getTableName() + " SET responsibleUser = NULL WHERE taskListID IN (SELECT taskListID FROM communitybase_task_tasklists WHERE sectionID = ?) AND responsibleUser = ?");

			query.addParameter(event.getSectionID());
			query.addParameter(event.getUserID());

			try {
				taskDAO.update(query);
			} catch (SQLException e) {
				log.warn("Exception while removing user " + event.getUserID() + " from unfinished tasks in section " + event.getSectionID(), e);
			}
		}
	}

}
