package se.sundsvall.collaborationroom.modules.utils;

import java.sql.Connection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import se.dosf.communitybase.beans.SectionFavourite;
import se.dosf.communitybase.dao.CBDAOFactory;
import se.dosf.communitybase.enums.SectionAccessMode;
import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.utils.CBSectionAttributeHelper;
import se.sundsvall.collaborationroom.modules.preferedsections.beans.PreferedSection;
import se.sundsvall.collaborationroom.modules.task.beans.Task;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.foregroundmodules.AnnotatedForegroundModule;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.LowLevelQuery;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.db.DBUtils;
import se.unlogic.webutils.http.URIParser;

/** Run once to remove invalid favorites and prefered section
 * 
 * @author exuvo */
public class CRCleanupModule extends AnnotatedForegroundModule {

	@InstanceManagerDependency(required = true)
	protected CBInterface cbInterface;

	private AnnotatedDAO<SectionFavourite> sectionFavouriteDAO;
	private AnnotatedDAO<PreferedSection> preferedSectionsDAO;
	private AnnotatedDAO<Task> taskDAO;

	protected QueryParameterFactory<SectionFavourite, Integer> sectionIDSectionFavoriteParameterFactory;
	protected QueryParameterFactory<SectionFavourite, Integer> userIDSectionFavoriteParameterFactory;
	private QueryParameterFactory<PreferedSection, Integer> userIDPreferedSectionParameterFactory;
	private QueryParameterFactory<PreferedSection, Integer> sectionIDPreferedSectionParameterFactory;
	private QueryParameterFactory<Task, User> responsibleUserIDTaskParameterFactory;

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		CBDAOFactory cbDAOFactory = new CBDAOFactory(dataSource, systemInterface.getUserHandler(), systemInterface.getGroupHandler());

		sectionFavouriteDAO = cbDAOFactory.getSectionFavouriteDAO();

		sectionIDSectionFavoriteParameterFactory = sectionFavouriteDAO.getParamFactory("sectionID", Integer.class);
		userIDSectionFavoriteParameterFactory = sectionFavouriteDAO.getParamFactory("userID", Integer.class);

		HierarchyAnnotatedDAOFactory annotatedDAOFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		preferedSectionsDAO = annotatedDAOFactory.getDAO(PreferedSection.class);
		userIDPreferedSectionParameterFactory = preferedSectionsDAO.getParamFactory("userID", Integer.class);
		sectionIDPreferedSectionParameterFactory = preferedSectionsDAO.getParamFactory("sectionID", Integer.class);

		taskDAO = annotatedDAOFactory.getDAO(Task.class);
		responsibleUserIDTaskParameterFactory = taskDAO.getParamFactory("responsibleUser", User.class);
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		if (user.isAdmin()) {

			Connection connection = dataSource.getConnection();

			try {

				int count = 0;

				log.warn("Removing section favorites for users who are not members in those non-open sections");

				List<SectionFavourite> sectionFavourites = sectionFavouriteDAO.getAll((HighLevelQuery<SectionFavourite>) null, connection);

				if (sectionFavourites != null) {
					for (SectionFavourite sectionFavourite : sectionFavourites) {

						List<Integer> members = cbInterface.getSectionMembers(sectionFavourite.getSectionID());

						if (members != null && !members.contains(sectionFavourite.getUserID())) {

							SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionFavourite.getSectionID());

							if (sectionInterface != null) {

								if (SectionAccessMode.OPEN.equals(CBSectionAttributeHelper.getAccessMode(sectionInterface.getSectionDescriptor()))) {
									continue;
								}
							}

							HighLevelQuery<SectionFavourite> query = new HighLevelQuery<SectionFavourite>();

							query.addParameter(sectionIDSectionFavoriteParameterFactory.getParameter(sectionFavourite.getSectionID()));
							query.addParameter(userIDSectionFavoriteParameterFactory.getParameter(sectionFavourite.getUserID()));

							sectionFavouriteDAO.delete(query, connection);
							count++;

							log.info("Removing section favorite " + sectionFavourite.getSectionID() + " for user " + sectionFavourite.getUserID());
						}
					}
				}

				log.warn("Removed " + count + " section favorites for users who are not members in those non-open sections");

				count = 0;

				log.warn("Removing prefered section for users who are not members in those non-open sections");

				List<PreferedSection> preferedSections = preferedSectionsDAO.getAll((HighLevelQuery<PreferedSection>) null, connection);

				if (sectionFavourites != null) {
					for (PreferedSection preferedSection : preferedSections) {

						List<Integer> members = cbInterface.getSectionMembers(preferedSection.getSectionID());

						if (members != null && !members.contains(preferedSection.getUserID())) {

							SectionInterface sectionInterface = systemInterface.getSectionInterface(preferedSection.getSectionID());

							if (sectionInterface != null) {

								if (SectionAccessMode.OPEN.equals(CBSectionAttributeHelper.getAccessMode(sectionInterface.getSectionDescriptor()))) {
									continue;
								}
							}

							HighLevelQuery<PreferedSection> query = new HighLevelQuery<PreferedSection>();

							query.addParameter(sectionIDPreferedSectionParameterFactory.getParameter(preferedSection.getSectionID()));
							query.addParameter(userIDPreferedSectionParameterFactory.getParameter(preferedSection.getUserID()));

							preferedSectionsDAO.delete(query, connection);
							count++;

							log.info("Removing prefered section link " + preferedSection.getSectionID() + " for user " + preferedSection.getUserID());
						}
					}
				}

				log.warn("Removed " + count + " prefered sections for users who are not members in those non-open sections");

				count = 0;

				log.warn("Removing task assignment for users who are not members in those sections");

				List<Task> tasks = taskDAO.getAll(new HighLevelQuery<Task>(responsibleUserIDTaskParameterFactory.getIsNotNullParameter(), Task.TASKLIST_RELATION), connection);

				if (sectionFavourites != null) {
					for (Task task : tasks) {

						Integer sectionID = task.getTaskList().getSectionID();

						List<Integer> members = cbInterface.getSectionMembers(sectionID);

						if (members != null && task.getResponsibleUser() != null && !members.contains(task.getResponsibleUser().getUserID())) {

							LowLevelQuery<Task> query = new LowLevelQuery<Task>("UPDATE " + taskDAO.getTableName() + " SET responsibleUser = NULL WHERE taskID = ?");

							query.addParameter(task.getTaskID());

							taskDAO.update(query, connection);
							count++;

							log.info("Removing task assignment " + task.getTaskID() + " for user " + task.getResponsibleUser());
						}
					}
				}

				log.warn("Removed " + count + " task assignments for users who are not members in those sections");

			} finally {
				DBUtils.closeConnection(connection);
			}
		}

		return null;
	}

}
