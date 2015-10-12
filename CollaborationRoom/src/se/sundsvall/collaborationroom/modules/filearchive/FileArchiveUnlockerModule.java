package se.sundsvall.collaborationroom.modules.filearchive;

import it.sauronsoftware.cron4j.Scheduler;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import se.sundsvall.collaborationroom.modules.filearchive.beans.Category;
import se.sundsvall.collaborationroom.modules.filearchive.beans.File;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.foregroundmodules.SimpleForegroundModule;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryOperators;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.dao.TransactionHandler;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.webutils.http.URIParser;

public class FileArchiveUnlockerModule extends SimpleForegroundModule implements Runnable {

	private Scheduler scheduler;

	private AnnotatedDAO<File> fileDAO;

	private QueryParameterFactory<File, Timestamp> lockedParamFactory;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		initScheduler();
	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, FileArchiveModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		fileDAO = daoFactory.getDAO(File.class);

		lockedParamFactory = fileDAO.getParamFactory("locked", Timestamp.class);

	}

	@Override
	public ForegroundModuleResponse processRequest(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception, Throwable {

		return null;
	}

	@Override
	public void run() {

		log.debug("Checking for files to unlock...");

		TransactionHandler transactionHandler = null;

		try {

			Timestamp currentTime = TimeUtils.getCurrentTimestamp();

			HighLevelQuery<File> query = new HighLevelQuery<File>(File.CATEGORY_RELATION);

			query.addParameter(lockedParamFactory.getParameter(currentTime, QueryOperators.SMALLER_THAN));

			List<File> files = fileDAO.getAll(query);

			if (files != null) {

				log.info("Found " + files.size() + " file(s) to unlock");

				transactionHandler = fileDAO.createTransaction();

				Set<Category> categoriesToCache = new HashSet<Category>();

				for (File file : files) {

					log.info("Unlocking file " + file + " locked by user " + file.getLockedBy() + " in category " + file.getCategory());

					file.setLocked(null);
					file.setLockedBy(null);

					fileDAO.update(file, transactionHandler, null);

					categoriesToCache.add(file.getCategory());

				}

				transactionHandler.commit();

				for (Category category : categoriesToCache) {

					SectionInterface sectionInterface = systemInterface.getSectionInterface(category.getSectionID());

					Entry<ForegroundModuleDescriptor, FileArchiveModule> fileArchiveModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(FileArchiveModule.class);

					if (fileArchiveModuleEntry != null) {

						FileArchiveModule fileArchiveModule = fileArchiveModuleEntry.getValue();

						fileArchiveModule.cacheCategory(category.getCategoryID());

					}

				}

			}

		} catch (SQLException e) {

			log.error("Error when trying to unlock files, aborting", e);

		} finally {

			TransactionHandler.autoClose(transactionHandler);

		}

	}

	protected synchronized void initScheduler() {

		scheduler = new Scheduler();

		scheduler.schedule("* * * * *", this);
		scheduler.start();
	}

	protected synchronized void stopScheduler() {

		try {

			if (scheduler != null) {

				scheduler.stop();
				scheduler = null;
			}

		} catch (IllegalStateException e) {
			log.error("Error stopping scheduler", e);
		}
	}

	@Override
	public void unload() throws Exception {

		stopScheduler();

		super.unload();
	}

}
