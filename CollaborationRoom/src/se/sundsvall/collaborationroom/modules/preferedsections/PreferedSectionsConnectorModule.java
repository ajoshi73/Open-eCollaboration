package se.sundsvall.collaborationroom.modules.preferedsections;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import se.dosf.communitybase.enums.SectionAccessMode;
import se.dosf.communitybase.events.CBMemberRemovedEvent;
import se.dosf.communitybase.events.CBSectionPreDeleteEvent;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.preferedsections.beans.PreferedSection;
import se.unlogic.hierarchy.core.annotations.EventListener;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.beans.SimpleSectionDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventSource;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.foregroundmodules.AnnotatedForegroundModule;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.dao.SimpleAnnotatedDAOFactory;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.webutils.http.URIParser;

public class PreferedSectionsConnectorModule extends AnnotatedForegroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Max section count", description = "The maximum number of prefered sections", formatValidator = PositiveStringIntegerValidator.class, required = true)
	private int maxPreferedSections = 3;
	
	private AnnotatedDAO<PreferedSection> preferedSectionsDAO;

	private QueryParameterFactory<PreferedSection, Integer> userIDParameterFactory;
	private QueryParameterFactory<PreferedSection, Integer> sectionIDParameterFactory;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		if (!systemInterface.getInstanceHandler().addInstance(PreferedSectionsConnectorModule.class, this)) {

			log.warn("Unable to register module " + moduleDescriptor + " in instance handler, another module is already registered for class " + PreferedSectionsConnectorModule.class.getName());
		}
	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, PreferedSectionsConnectorModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		SimpleAnnotatedDAOFactory daoFactory = new SimpleAnnotatedDAOFactory(dataSource);

		preferedSectionsDAO = daoFactory.getDAO(PreferedSection.class);
		userIDParameterFactory = preferedSectionsDAO.getParamFactory("userID", Integer.class);
		sectionIDParameterFactory = preferedSectionsDAO.getParamFactory("sectionID", Integer.class);
	}

	@WebPublic(alias = "add")
	public ForegroundModuleResponse add(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer sectionID = uriParser.getInt(2);

		if (sectionID != null) {

			List<Integer> sectionIDs = CBAccessUtils.getUserSections(user);

			if (sectionIDs != null && sectionIDs.contains(sectionID) && getPreferedSectionCount(user) < maxPreferedSections) {

				PreferedSection preferedSection = new PreferedSection(user.getUserID(), sectionID);

				preferedSectionsDAO.addOrUpdate(preferedSection, null);
			
			}

		}
		
		redirectToCurrentSection(req, res);

		return null;

	}

	@WebPublic(alias = "delete")
	public ForegroundModuleResponse delete(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		PreferedSection preferedSection = null;

		Integer sectionID = uriParser.getInt(2);

		if (sectionID != null && (preferedSection = getPreferedSection(user, sectionID)) != null) {

			delete(preferedSection);

		}

		redirectToCurrentSection(req, res);

		return null;
	}

	public void delete(PreferedSection preferedSection) throws SQLException {
		
		preferedSectionsDAO.delete(preferedSection);		
	}
	
	public List<PreferedSection> getPreferedSections(User user) throws SQLException {

		HighLevelQuery<PreferedSection> query = new HighLevelQuery<PreferedSection>();

		query.addParameter(userIDParameterFactory.getParameter(user.getUserID()));

		return preferedSectionsDAO.getAll(query);
	}

	public PreferedSection getPreferedSection(User user, Integer sectionID) throws SQLException {

		HighLevelQuery<PreferedSection> query = new HighLevelQuery<PreferedSection>();

		query.addParameter(userIDParameterFactory.getParameter(user.getUserID()));
		query.addParameter(sectionIDParameterFactory.getParameter(sectionID));

		return preferedSectionsDAO.get(query);

	}
	
	public Integer getPreferedSectionCount(User user) throws SQLException {

		HighLevelQuery<PreferedSection> query = new HighLevelQuery<PreferedSection>();

		query.addParameter(userIDParameterFactory.getParameter(user.getUserID()));

		return preferedSectionsDAO.getCount(query);

	}

	@Override
	public void unload() throws Exception {

		systemInterface.getInstanceHandler().removeInstance(PreferedSectionsConnectorModule.class, this);

		super.unload();
	}
	
	public int getMaxPreferedSections() {
		
		return maxPreferedSections;
	}
	
	private void redirectToCurrentSection(HttpServletRequest req, HttpServletResponse res) throws IOException {
		
		String redirect = req.getContextPath() + sectionInterface.getSectionDescriptor().getFullAlias();
		
		if(StringUtils.isEmpty(redirect)) {
			redirect = "/";
		}
	
		res.sendRedirect(redirect);
	}

	@EventListener(channel = SimpleSectionDescriptor.class)
	public void processEvent(CBSectionPreDeleteEvent event, EventSource source) {

		HighLevelQuery<PreferedSection> query = new HighLevelQuery<PreferedSection>(sectionIDParameterFactory.getParameter(event.getSectionID()));

		try {
			preferedSectionsDAO.delete(query);
		} catch (SQLException e) {

			log.warn("Unable to delete prefered section links to section marked for deletion", e);
		}
	}

	@EventListener(channel = SimpleSectionDescriptor.class)
	public void processEvent(CBMemberRemovedEvent event, EventSource source) {

		if (SectionAccessMode.CLOSED.equals(event.getSectionAccessMode()) || SectionAccessMode.HIDDEN.equals(event.getSectionAccessMode())) {

			HighLevelQuery<PreferedSection> query = new HighLevelQuery<PreferedSection>();

			query.addParameter(sectionIDParameterFactory.getParameter(event.getSectionID()));
			query.addParameter(userIDParameterFactory.getParameter(event.getUserID()));

			try {
				preferedSectionsDAO.delete(query);
			} catch (SQLException e) {

				log.warn("Unable to delete prefered section links for user (" + event.getUserID() + ") removed from section (" + event.getSectionID() + ")", e);
			}
		}
	}
}
