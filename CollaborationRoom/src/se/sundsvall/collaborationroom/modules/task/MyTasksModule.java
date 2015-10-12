package se.sundsvall.collaborationroom.modules.task;

import java.sql.SQLException;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.task.beans.Task;
import se.sundsvall.collaborationroom.modules.task.beans.TaskElementableListener;
import se.sundsvall.collaborationroom.modules.task.beans.TaskList;
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
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.LowLevelQuery;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.xml.XMLGeneratorDocument;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;

public class MyTasksModule extends AnnotatedForegroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Deadline treshold (days)", description = "The number of days before a task is being marked as 'is about to miss deadline'", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private int deadlineThreshold = 3;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Tasks load count", description = "The number of tasks to return when calling gettasts method", required = true)
	private Integer taskLoadCount = 5;

	@InstanceManagerDependency(required = true)
	private CBInterface cbInterface;

	private AnnotatedDAO<Task> taskDAO;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		if (!systemInterface.getInstanceHandler().addInstance(MyTasksModule.class, this)) {

			log.warn("Unable to register module " + moduleDescriptor + " in instance handler, another module is already registered for class " + MyTasksModule.class.getName());
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

		taskDAO = daoFactory.getDAO(Task.class);
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		log.info("User " + user + " listing tasks");
		
		Document doc = createDocument(req, uriParser, user);

		Element myTaskListsElement = XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "MyTasks");

		List<Integer> sectionIDs = CBAccessUtils.getUserSections(user);

		if (sectionIDs != null) {

			XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

			TaskElementableListener elementableListener = new TaskElementableListener();

			generatorDocument.addElementableListener(Task.class, elementableListener);

			for (Integer sectionID : sectionIDs) {

				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

				if (sectionInterface != null) {

					Entry<ForegroundModuleDescriptor, TaskModule> taskModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(TaskModule.class);

					if (taskModuleEntry != null) {

						Element taskModuleElement = XMLUtils.appendNewElement(doc, myTaskListsElement, "TaskModule");

						XMLUtils.appendNewElement(doc, taskModuleElement, "sectionID", sectionID);
						XMLUtils.appendNewElement(doc, taskModuleElement, "sectionName", sectionInterface.getSectionDescriptor().getName());
						XMLUtils.appendNewElement(doc, taskModuleElement, "fullAlias", sectionInterface.getSectionDescriptor().getFullAlias() + "/" + taskModuleEntry.getKey().getAlias());

						appendAllMembers(doc, taskModuleElement, sectionID);

						Collection<TaskList> taskLists = taskModuleEntry.getValue().getCachedTaskLists();

						if (taskLists != null) {

							elementableListener.setDeadlineThreshold(taskModuleEntry.getValue().getDeadlineThreshold());

							for (TaskList taskList : taskLists) {

								myTaskListsElement.appendChild(taskList.toXML(generatorDocument));
							}

						}

					}

				}

			}

		}

		return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());
	}

	public void appendAllMembers(Document doc, Element element, Integer sectionID) {

		List<Integer> userIDs = cbInterface.getSectionMembers(sectionID);

		if (!CollectionUtils.isEmpty(userIDs)) {
			XMLUtils.append(doc, element, "members", systemInterface.getUserHandler().getUsers(userIDs, false, false));
		}

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

		appendAdditionalTasks(doc, listPostsElement, startIndex, user, req);

		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		return moduleResponse;
	}

	public void appendAdditionalTasks(Document doc, Element element, int startIndex, User user, HttpServletRequest req) throws SQLException {

		TaskElementableListener elementableListener = new TaskElementableListener(deadlineThreshold);

		Map<Integer, String> userTaskAliasMap = getUserTasksAliasMap(user, req);

		if (!CollectionUtils.isEmpty(userTaskAliasMap)) {

			List<Task> tasks = this.getActiveTasks(startIndex, taskLoadCount, user, userTaskAliasMap.keySet());

			if (tasks != null) {

				for (Task task : tasks) {

					Integer sectionID = task.getTaskList().getSectionID();
					
					task.setResponsibleUser(null);
					task.setModuleAlias(userTaskAliasMap.get(sectionID));
					task.setSectionName(systemInterface.getSectionInterface(sectionID).getSectionDescriptor().getName());
					
					Element taskElement = task.toXML(doc);

					elementableListener.elementGenerated(doc, taskElement, task);

					element.appendChild(taskElement);
				}

			}

		}

	}

	private Map<Integer, String> getUserTasksAliasMap(User user, HttpServletRequest req) {

		List<Integer> sectionIDs = CBAccessUtils.getUserSections(user);

		if (sectionIDs != null) {

			Map<Integer, String> map = new HashMap<Integer, String>();

			for (Integer sectionID : sectionIDs) {

				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

				if (sectionInterface != null) {

					Entry<ForegroundModuleDescriptor, TaskModule> taskModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(TaskModule.class);

					if (taskModuleEntry != null) {

						map.put(sectionID, req.getContextPath() + taskModuleEntry.getValue().getFullAlias());
					}

				}

			}

			return map;

		}

		return null;
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

		XMLUtils.appendNewElement(doc, document, "hasManageAccess", true);
		
		doc.appendChild(document);

		return doc;
	}

	public List<Task> getActiveTasks(int startIndex, int taskLoadCount, User user, Collection<Integer> sectionIDs) throws SQLException {

		LowLevelQuery<Task> query = new LowLevelQuery<Task>();

		query.setSql("SELECT * FROM " + taskDAO.getTableName() + " AS t "
				+ "LEFT JOIN " + TaskList.TASKLIST_TABLE_NAME + " AS tl ON(t.taskListID = tl.taskListID) "
				+ "WHERE tl.sectionID IN(" + StringUtils.toCommaSeparatedString(sectionIDs) + ") AND t.responsibleUser = ? AND t.finished IS NULL ORDER BY CASE WHEN t.deadLine IS NULL THEN 1 ELSE 0 END, t.deadLine LIMIT ?, ?");

		query.addParameter(user.getUserID());
		query.addParameter(startIndex);
		query.addParameter(taskLoadCount);

		query.addRelation(Task.TASKLIST_RELATION);

		return taskDAO.getAll(query);
	}

	@Override
	public void unload() throws Exception {

		systemInterface.getInstanceHandler().removeInstance(MyTasksModule.class, this);

		super.unload();
	}

}
