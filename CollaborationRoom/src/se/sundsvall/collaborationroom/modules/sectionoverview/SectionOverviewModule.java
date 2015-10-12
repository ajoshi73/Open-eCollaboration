package se.sundsvall.collaborationroom.modules.sectionoverview;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.enums.NotificationFormat;
import se.dosf.communitybase.events.CBSectionPreDeleteEvent;
import se.dosf.communitybase.interfaces.Notification;
import se.dosf.communitybase.interfaces.NotificationHandler;
import se.dosf.communitybase.interfaces.NotificationTransformer;
import se.dosf.communitybase.interfaces.StorageUsage;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.deletesection.DeleteSectionModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.modules.util.CBUtilityModule;
import se.dosf.communitybase.utils.CBSectionAttributeHelper;
import se.unlogic.hierarchy.core.annotations.HTMLEditorSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.beans.Group;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.SimpleSectionDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModule;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.collections.KeyNotCachedException;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.io.BinarySizeFormater;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class SectionOverviewModule extends CBBaseModule implements NotificationTransformer {

	@ModuleSetting
	@HTMLEditorSettingDescriptor(name = "Delete section message", description = "Delete message to displayed on the warning/confirmation page. The $section.name tag is supported.", required = true)
	private String message = "not set";

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Notification stylesheet", description = "The stylesheet used to transform notifications")
	private String notificationStylesheet = "SectionOverviewNotification.sv.xsl";

	@InstanceManagerDependency(required = false)
	private CBUtilityModule cbUtilityModule;

	@InstanceManagerDependency(required = false)
	protected NotificationHandler notificationHandler;

	private SimpleViewFragmentTransformer notificationFragmentTransformer;

	@InstanceManagerDependency(required = false)
	protected DeleteSectionModule deleteSectionModule;

	@InstanceManagerDependency(required = false)
	protected UserProfileProvider userProfileProvider;

	@Override
	protected void moduleConfigured() throws Exception {

		super.moduleConfigured();

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
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		Document doc = createDocument(req, uriParser, user);
		Element overviewElement = doc.createElement("SectionOverview");
		doc.getFirstChild().appendChild(overviewElement);

		XMLUtils.appendNewElement(doc, overviewElement, "SectionCount", getSectionCount());
		
		if (cbUtilityModule != null) {
			XMLUtils.appendNewElement(doc, overviewElement, "CBUtilityModuleAlias", cbUtilityModule.getFullAlias());
		}

		Element sectionsElement = doc.createElement("Sections");
		overviewElement.appendChild(sectionsElement);
		
		List<SimpleSectionDescriptor> sections = systemInterface.getCoreDaoFactory().getSectionDAO().getSectionsByAttribute("sectionTypeID", true);

		long totalStorage = 0;

		if (!CollectionUtils.isEmpty(sections)) {
			for (SimpleSectionDescriptor section : sections) {

				Integer sectionID = section.getSectionID();

				Element sectionElement = section.toXML(doc);
				sectionsElement.appendChild(sectionElement);
				
				long usedStorage = getFilestoreUsage(sectionID);
				totalStorage += usedStorage;

				XMLUtils.appendNewElement(doc, sectionElement, "FilestoreUsageBytes", usedStorage);
				XMLUtils.appendNewElement(doc, sectionElement, "FilestoreUsage", org.apache.commons.io.FileUtils.byteCountToDisplaySize(usedStorage));
				XMLUtils.appendNewElement(doc, sectionElement, "MemberCount", getSectionMemberCount(sectionID));
				XMLUtils.append(doc, sectionElement, CBSectionAttributeHelper.getSectionType(section, cbInterface));
				XMLUtils.appendNewElement(doc, sectionElement, "Deleted", CBSectionAttributeHelper.getDeleted(section));

				if (deleteSectionModule != null) {
					XMLUtils.appendNewElement(doc, sectionElement, "DaysRemaining", deleteSectionModule.getDaysRemainingBeforePermantentDeletion(section));
				}

				sectionsElement.appendChild(sectionElement);
			}
		}

		XMLUtils.appendNewElement(doc, overviewElement, "TotalFilestoreUsage", BinarySizeFormater.getFormatedSize(totalStorage));

		return new SimpleForegroundModuleResponse(doc, moduleDescriptor.getName(), getDefaultBreadcrumb());
	}
	
	private Integer getSectionMemberCount(Integer sectionID) {

		List<Integer> memberIDs = cbInterface.getSectionMembers(sectionID);

		if (memberIDs == null || memberIDs.isEmpty()) { //Might be a deleted section which is not cached

			List<Group> groups = cbInterface.getRoleGroups(sectionID, false);

			if (groups == null) {
				return 0;
			}

			Set<Integer> sectionMembers = new HashSet<Integer>();

			for (Group group : groups) {

				List<User> users = systemInterface.getUserHandler().getUsersByGroup(group.getGroupID(), false, false);

				if (users != null) {

					for (User user : users) {

						sectionMembers.add(user.getUserID());

					}

				}

			}

			return sectionMembers.size();
		}

		return memberIDs.size();
	}

	private Integer getSectionCount() throws SQLException {
		
		List<Integer> ids = systemInterface.getCoreDaoFactory().getSectionAttributeDAO().getIDsByAttribute("sectionTypeID");

		if (ids == null) {
			return 0;
		}
		
		return ids.size();
	}

	private long getFilestoreUsage(Integer sectionID) {

		SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

		if (sectionInterface == null) {
			return 0;
		}
		
		long storage = 0;
		
		for (Entry<ForegroundModuleDescriptor, ForegroundModule> entry : sectionInterface.getForegroundModuleCache().getCachedModules()) {
			
			if (StorageUsage.class.isAssignableFrom(entry.getValue().getClass())) {

				StorageUsage storageUser = (StorageUsage) entry.getValue();

				storage += storageUser.getUsedStorage();
			}
		}

		return storage;
	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		if (cbUtilityModule != null) {
			XMLUtils.appendNewElement(doc, (Element) doc.getFirstChild(), "CBUtilityModuleAlias", cbUtilityModule.getFullAlias());
		}

		return doc;
	}

	@WebPublic(alias = "warning")
	public ForegroundModuleResponse showWarning(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		SimpleSectionDescriptor sectionDescriptor = getSection(uriParser, user);

		Document doc = createDocument(req, uriParser, user);
		Element warningElement = doc.createElement("DeleteWarning");
		doc.getFirstChild().appendChild(warningElement);

		XMLUtils.appendNewElement(doc, warningElement, "FullAlias", getFullAlias());
		XMLUtils.appendNewElement(doc, warningElement, "SectionID", sectionDescriptor.getSectionID());
		XMLUtils.appendNewElement(doc, warningElement, "Message", message.replace("$section.name", sectionDescriptor.getName()));

		return new SimpleForegroundModuleResponse(doc, moduleDescriptor.getName(), getDefaultBreadcrumb());
	}

	@WebPublic(alias = "delete")
	public ForegroundModuleResponse deleteRoom(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		SimpleSectionDescriptor sectionDescriptor = getSection(uriParser, user);

		if (sectionDescriptor != null && CBSectionAttributeHelper.getDeleted(sectionDescriptor) == null) {

			log.info("User " + user + " marking section " + sectionDescriptor + " for deletion");

			SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionDescriptor.getSectionID());

			//Stop the section if it is started
			if (sectionInterface != null) {

				try {
					sectionInterface.getParentSectionInterface().getSectionCache().unload(sectionDescriptor);
				} catch (KeyNotCachedException e) {}
			}

			sectionDescriptor.setEnabled(false);

			CBSectionAttributeHelper.setDeleted(sectionDescriptor, TimeUtils.getCurrentTimestamp());

			systemInterface.getCoreDaoFactory().getSectionDAO().update(sectionDescriptor);

			if (notificationHandler != null) {

				List<Integer> userIDs = cbInterface.getSectionMembers(sectionDescriptor.getSectionID());

				if (!CollectionUtils.isEmpty(userIDs)) {

					for (Integer userID : userIDs) {

						HashMap<String, String> attributes = new HashMap<String, String>();
						attributes.put("SectionName", sectionDescriptor.getName());

						notificationHandler.addNotification(userID, this.getSectionID(), this.moduleDescriptor.getModuleID(), "deleted", user.getUserID(), attributes);
					}
				}
			}

			this.systemInterface.getEventHandler().sendEvent(SimpleSectionDescriptor.class, new CBSectionPreDeleteEvent(sectionDescriptor.getSectionID()), EventTarget.ALL);
		}

		res.sendRedirect(req.getContextPath() + getFullAlias());

		return null;
	}

	@WebPublic(alias = "restore")
	public ForegroundModuleResponse restoreRoom(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		SimpleSectionDescriptor sectionDescriptor = getSection(uriParser, user);

		if (sectionDescriptor != null && CBSectionAttributeHelper.getDeleted(sectionDescriptor) != null) {

			log.info("User " + user + " restoring section " + sectionDescriptor + " from deletion");

			CBSectionAttributeHelper.setDeleted(sectionDescriptor, null);

			sectionDescriptor.setEnabled(true);

			systemInterface.getCoreDaoFactory().getSectionDAO().update(sectionDescriptor);

			SectionInterface parentSectionInterface = systemInterface.getSectionInterface(sectionDescriptor.getParentSectionID());

			try {
				parentSectionInterface.getSectionCache().cache(sectionDescriptor);
			} catch (KeyNotCachedException e) {}

			if (notificationHandler != null) {

				List<Integer> userIDs = cbInterface.getSectionMembers(sectionDescriptor.getSectionID());

				if (!CollectionUtils.isEmpty(userIDs)) {

					for (Integer userID : userIDs) {

						HashMap<String, String> attributes = new HashMap<String, String>();
						attributes.put("SectionID", "" + sectionDescriptor.getSectionID());
						attributes.put("SectionName", sectionDescriptor.getName());

						notificationHandler.addNotification(userID, this.getSectionID(), this.moduleDescriptor.getModuleID(), "restored", user.getUserID(), attributes);
					}
				}
			}
		}

		res.sendRedirect(req.getContextPath() + getFullAlias());

		return null;
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

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		User poster = systemInterface.getUserHandler().getUser(notification.getExternalNotificationID(), false, false);

		if (poster != null) {

			documentElement.appendChild(poster.toXML(doc));
		}

		XMLUtils.appendNewElement(doc, documentElement, "NotificationType", notification.getNotificationType());
		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		XMLUtils.appendNewElement(doc, documentElement, "Posted", DateUtils.DATE_TIME_FORMATTER.format(notification.getAdded()));
		XMLUtils.appendNewElement(doc, documentElement, "ModuleName", moduleDescriptor.getName());

		XMLUtils.appendNewElement(doc, documentElement, "SectionName", notification.getAttributeHandler().getString("SectionName"));

		if (notification.getAttributeHandler().isSet("SectionID")) {
			XMLUtils.appendNewElement(doc, documentElement, "SectionID", notification.getAttributeHandler().getString("SectionID"));
		}

		if (!notification.isRead()) {

			XMLUtils.appendNewElement(doc, documentElement, "Unread");
		}

		return transformer.createViewFragment(doc);
	}

	private SimpleSectionDescriptor getSection(URIParser uriParser, User user) throws URINotFoundException, SQLException, AccessDeniedException {

		Integer sectionID = uriParser.getInt(2);

		if (sectionID == null) {

			throw new URINotFoundException(uriParser);
		}

		SimpleSectionDescriptor sectionDescriptor = systemInterface.getCoreDaoFactory().getSectionDAO().getSection(sectionID, true);

		if (sectionDescriptor == null) {

			throw new URINotFoundException(uriParser);
		}

		return sectionDescriptor;
	}

}
