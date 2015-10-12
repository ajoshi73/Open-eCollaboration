package se.sundsvall.collaborationroom.modules.utils;

import java.io.File;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import se.unlogic.hierarchy.core.annotations.EventListener;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleSectionDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.CRUDAction;
import se.unlogic.hierarchy.core.enums.EventSource;
import se.unlogic.hierarchy.core.events.CRUDEvent;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.foregroundmodules.AnnotatedForegroundModule;
import se.unlogic.standardutils.io.FileUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.webutils.http.URIParser;

public class FilestoreDeleterModule extends AnnotatedForegroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "File Archive Base filestore", description = "Directory where section filearchive directory is created")
	protected String fileArchiveFilestore;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Pages Base filestore", description = "Directory where section page directory is created")
	protected String pagesFilestore;

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		if (!StringUtils.isEmpty(fileArchiveFilestore)) {

			checkForDeletedSectionFileStores(fileArchiveFilestore);
		}

		if (!StringUtils.isEmpty(pagesFilestore)) {

			checkForDeletedSectionFileStores(pagesFilestore);
		}

		return super.defaultMethod(req, res, user, uriParser);
	}

	private void checkForDeletedSectionFileStores(String baseFilestore) throws SQLException {

		File filestore = new File(baseFilestore);

		String name = filestore.getName();

		log.info("Checking for orphaned " + name + " filestores");

		if (FileUtils.isReadable(filestore)) {

			File[] sections = filestore.listFiles();

			//Check if filestore seems correct
			for (File directory : sections) {

				if (directory.isDirectory()) {
					try {
						Integer.parseInt(directory.getName());

					} catch (NumberFormatException e) {
						log.warn("Aborting, unable to parse section ID from directory name \"" + directory.getName() + "\". Verify that the filestore setting \"" + baseFilestore + "\" is correct.");
						return;
					}

				} else {
					log.warn("Aborting, found non-directory file \"" + directory.getName() + "\". Verify that the filestore setting \"" + baseFilestore + "\" is correct.");
					return;
				}
			}

			for (File directory : sections) {

				if (directory.isDirectory()) {
					try {
						Integer sectionID = Integer.parseInt(directory.getName());

						SimpleSectionDescriptor sectionDescriptor = systemInterface.getCoreDaoFactory().getSectionDAO().getSection(sectionID, false);

						if (sectionDescriptor == null) {

							log.info("Deleting " + name + " filestore for section " + sectionID);
							FileUtils.deleteDirectory(directory);
						}

					} catch (NumberFormatException e) {
						log.warn("Unable to parse section ID from directory name \"" + directory + "\".");
					}

				} else {
					log.warn("Found non-directory file \"" + directory + "\".");
				}
			}

		} else {
			log.warn("Unable to read from " + filestore);
		}
	}

	@EventListener(channel = SimpleSectionDescriptor.class)
	public void processEvent(CRUDEvent<SimpleSectionDescriptor> event, EventSource eventSource) {

		if (event.getAction().equals(CRUDAction.DELETE)) {
			for (SimpleSectionDescriptor section : event.getBeans()) {

				if (!StringUtils.isEmpty(fileArchiveFilestore)) {

					deleteFileStore(fileArchiveFilestore, section.getSectionID());
				}

				if (!StringUtils.isEmpty(pagesFilestore)) {

					deleteFileStore(pagesFilestore, section.getSectionID());
				}
			}
		}
	}

	private void deleteFileStore(String baseFilestore, Integer sectionID) {

		File filestore = new File(baseFilestore + File.separator + sectionID);

		log.info("Deleting " + new File(baseFilestore).getName() + " filestore for section " + sectionID);
		FileUtils.deleteDirectory(filestore);
	}

}
