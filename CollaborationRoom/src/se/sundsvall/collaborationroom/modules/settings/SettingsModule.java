package se.sundsvall.collaborationroom.modules.settings;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.CBConstants;
import se.dosf.communitybase.enums.ModuleManagementMode;
import se.dosf.communitybase.enums.NotificationFormat;
import se.dosf.communitybase.enums.SectionAccessMode;
import se.dosf.communitybase.events.CBSectionAccessModeChangedEvent;
import se.dosf.communitybase.interfaces.ForegroundModuleConfiguration;
import se.dosf.communitybase.interfaces.Notification;
import se.dosf.communitybase.interfaces.NotificationHandler;
import se.dosf.communitybase.interfaces.NotificationTransformer;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.deletesection.DeleteSectionModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.modules.util.CBUtilityModule;
import se.dosf.communitybase.utils.CBSectionAttributeHelper;
import se.unlogic.fileuploadutils.MultipartRequest;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.SimpleSectionDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.crud.MultipartLimitProvider;
import se.unlogic.hierarchy.core.utils.crud.MultipartRequestFilter;
import se.unlogic.hierarchy.foregroundmodules.systemadmin.SectionUpdater;
import se.unlogic.standardutils.bool.BooleanUtils;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.image.ImageUtils;
import se.unlogic.standardutils.io.BinarySizeFormater;
import se.unlogic.standardutils.io.BinarySizes;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.populators.EnumPopulator;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.validation.StringIntegerValidator;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.validation.ValidationUtils;

public class SettingsModule extends CBBaseModule implements MultipartLimitProvider, NotificationTransformer {

	private static final EnumPopulator<SectionAccessMode> ACCESS_MODE_POPULATOR = new EnumPopulator<SectionAccessMode>(SectionAccessMode.class);

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Max upload size", description = "Maxmium upload size in megabytes allowed in a single post request", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private Integer maxRequestSize = 100;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "RAM threshold", description = "Maximum size of files in KB to be buffered in RAM during file uploads. Files exceeding the threshold are written to disk instead.", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private Integer ramThreshold = 500;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Section image max size (in px)", description = "The max size of the section image (default is 270)", required = true, formatValidator = StringIntegerValidator.class)
	protected Integer sectionImageSize = 270;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Notification stylesheet", description = "The stylesheet used to transform notifications")
	private String notificationStylesheet = "SettingsNotification.sv.xsl";

	@InstanceManagerDependency(required = false)
	private CBUtilityModule cbUtilityModule;

	@InstanceManagerDependency(required = false)
	protected NotificationHandler notificationHandler;

	@InstanceManagerDependency(required = false)
	protected DeleteSectionModule deleteSectionModule;

	protected MultipartRequestFilter multipartFilter = new MultipartRequestFilter(this);

	private Integer sourceModuleID;

	private SimpleViewFragmentTransformer notificationFragmentTransformer;

	@InstanceManagerDependency(required = false)
	protected UserProfileProvider userProfileProvider;

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		Integer sectionID = sectionInterface.getSectionDescriptor().getSectionID();

		SimpleSectionDescriptor sectionDescriptor = systemInterface.getCoreDaoFactory().getSectionDAO().getSection(sectionID, true);
		
		Role role = cbInterface.getRole(sectionID, user);

		if(role == null){

			throw new RuntimeException("Unable to find role for user " + user + " in section " + sectionInterface.getSectionDescriptor());
		}

		Integer sectionType = CBSectionAttributeHelper.getSectionTypeID(sectionDescriptor);

		if (sectionType == null) {

			throw new RuntimeException("Unable to find section type for section " + sectionDescriptor);
		}

		List<? extends ForegroundModuleConfiguration> supportedForegroundModules = cbInterface.getSupportedForegroundModules(sectionType);

		List<SimpleForegroundModuleDescriptor> moduleDescriptors = systemInterface.getCoreDaoFactory().getForegroundModuleDAO().getModules(sectionID);

		List<ValidationError> validationErrors = null;

		if(req.getMethod().equals("POST")) {

			validationErrors = new ArrayList<ValidationError>();

			try {
				req = multipartFilter.parseRequest(req, user);

				String description = ValidationUtils.validateParameter("description", req, false, 0, 4096, validationErrors);
				SectionAccessMode accessMode = null;
				String name = null;
				String oldName = sectionDescriptor.getName();

				if(role.hasManageSectionAccessModeAccess()){

					accessMode = ValidationUtils.validateParameter("accessMode", req, true, ACCESS_MODE_POPULATOR, validationErrors);
					name = ValidationUtils.validateParameter("name", req, false, 0, 255, validationErrors);
				}

				BufferedImage logo = getLogo(req, validationErrors);

				if(validationErrors.isEmpty()){

					log.info("User " + user + " updating settings for section " + sectionInterface.getSectionDescriptor());

					CBSectionAttributeHelper.setDescription(sectionDescriptor, description);

					if(role.hasManageArchivedAccess()){

						CBSectionAttributeHelper.setArchived(sectionDescriptor, BooleanUtils.toBoolean(req.getParameter("archived")));
					}

					SectionAccessMode prevAccessMode = CBSectionAttributeHelper.getAccessMode(sectionDescriptor);

					if (accessMode != null && !accessMode.equals(prevAccessMode)) {

						cbInterface.setSectionAccess(sectionDescriptor, accessMode);

						this.systemInterface.getEventHandler().sendEvent(SimpleSectionDescriptor.class, new CBSectionAccessModeChangedEvent(sectionDescriptor.getSectionID(), prevAccessMode, accessMode), EventTarget.ALL);

					}else{

						//TODO send event for search to pickup changes in the description
					}

					if (!StringUtils.isEmpty(name) && !name.equals(oldName)) {

						cbInterface.setSectionName(sectionDescriptor, name);

						if (notificationHandler != null) {
							List<Integer> userIDs = cbInterface.getSectionMembers(sectionID);
							
							if (!CollectionUtils.isEmpty(userIDs)) {

								for (Integer userID : userIDs) {

									//add a new notification using the old name as notification type since the module only produces one type of notifications
									notificationHandler.addNotification(userID, sectionID, sourceModuleID, oldName, user.getUserID(), null);
								}
							}
						}
					}

					systemInterface.getCoreDaoFactory().getSectionDAO().update(sectionDescriptor);

					SectionUpdater sectionUpdater = new SectionUpdater(sectionInterface.getParentSectionInterface().getSectionCache(), sectionDescriptor, user);
					sectionUpdater.isDaemon();
					sectionUpdater.start();

					if(logo != null){

						//Update logo
						log.info("User " + user + " setting new logo for section " + sectionInterface.getSectionDescriptor());
						cbInterface.setSectionLogo(sectionID, logo);

					}else if(BooleanUtils.toBoolean(req.getParameter("deleteLogo"))){

						//Delete logo
						log.info("User " + user + " removing logo from section " + sectionInterface.getSectionDescriptor());
						cbInterface.deleteSectionLogo(sectionID);
					}

					if(role.hasManageModulesAccess() && supportedForegroundModules != null){

						boolean hasChanges = false;

						List<Integer> sourceModuleIDs = NumberUtils.toInt(req.getParameterValues("moduleID"));

						for(ForegroundModuleConfiguration moduleConfiguration : supportedForegroundModules){

							if(moduleConfiguration.getManagementMode() != ModuleManagementMode.MANAGEABLE){

								continue;
							}

							SimpleForegroundModuleDescriptor matchingModuleDescriptor = getMatchingModuleDescriptor(moduleConfiguration.getModuleID(), moduleDescriptors);

							//Check if this module should be enabled or not
							if(sourceModuleIDs != null && sourceModuleIDs.contains(moduleConfiguration.getModuleID())){

								//This module should be enabled, check if it already is

								if(matchingModuleDescriptor == null){

									SimpleForegroundModuleDescriptor addedDescriptor = cbInterface.addForegroundModule(sectionID, sectionType, moduleConfiguration);

									if(addedDescriptor != null){

										//This  needs to be added to this section
										log.info("User " + user + " adding module " + addedDescriptor + " to section " + sectionInterface.getSectionDescriptor());

										sectionInterface.getForegroundModuleCache().cache(addedDescriptor);

										hasChanges = true;

									}else{

										log.warn("Unable to add foreground module based on module ID " + moduleConfiguration.getModuleID() + " to section " + sectionInterface.getSectionDescriptor());
									}
								}

							}else if(matchingModuleDescriptor != null){

								//This module is enabled but should to be disabled
								log.info("User " + user + " removing module " + moduleDescriptors + " from section " + sectionInterface.getSectionDescriptor());

								sectionInterface.getForegroundModuleCache().unload(matchingModuleDescriptor);

								systemInterface.getCoreDaoFactory().getForegroundModuleDAO().delete(matchingModuleDescriptor);

								if(notificationHandler != null){

									try{
										notificationHandler.disableNotifications(sectionID, moduleConfiguration.getModuleID());

									}catch(Exception e){

										log.error("Error disabling notifications for module " + moduleDescriptor + " removed from section " + sectionInterface.getSectionDescriptor(), e);
									}
								}
							}
						}

						if(hasChanges){

							cbInterface.sortMenu(sectionInterface);
						}
					}

					redirectToDefaultMethod(req, res);

					return null;
				}

			}catch (ValidationException e){

				validationErrors = e.getErrors();

			} finally {

				multipartFilter.releaseRequest(req, user);
			}
		}

		log.info("User " + user + " requested section settings form for section " + sectionInterface.getSectionDescriptor());

		Document doc = createDocument(req, uriParser, user);
		Element documentElement = doc.getDocumentElement();

		Element sectionSettingsElement = doc.createElement("SectionSettings");
		documentElement.appendChild(sectionSettingsElement);

		XMLUtils.appendNewElement(doc, sectionSettingsElement, "MaxAllowedFileSize", BinarySizeFormater.getFormatedSize(maxRequestSize * BinarySizes.MegaByte));

		if(cbUtilityModule != null) {
			XMLUtils.appendNewElement(doc, sectionSettingsElement, "SectionLogoURI", req.getContextPath() + cbUtilityModule.getFullAlias() + "/sectionlogo/" + sectionID + "?" + cbUtilityModule.getSectionLogoLastModified(sectionID));
		}

		if(role.hasDeleteRoomAccess() && deleteSectionModule != null){

			XMLUtils.appendNewElement(doc, sectionSettingsElement, "DeleteSectionURI", req.getContextPath() + deleteSectionModule.getDeleteSectionAlias(sectionID));
		}

		sectionSettingsElement.appendChild(role.toXML(doc));
		sectionSettingsElement.appendChild(sectionDescriptor.toXML(doc));

		if(cbInterface.getSectionLogo(sectionID) != null){

			XMLUtils.appendNewElement(doc, sectionSettingsElement, "HasLogo");
		}

		if(supportedForegroundModules != null){

			Element supportedForegroundModulesElement = doc.createElement("SupportedForegroundModules");
			sectionSettingsElement.appendChild(supportedForegroundModulesElement);

			for(ForegroundModuleConfiguration moduleConfiguration : supportedForegroundModules){

				Element moduleConfigurationElement = moduleConfiguration.toXML(doc);
				supportedForegroundModulesElement.appendChild(moduleConfigurationElement);

				//Append module descriptor if available
				XMLUtils.append(doc, moduleConfigurationElement, systemInterface.getCoreDaoFactory().getForegroundModuleDAO().getModule(moduleConfiguration.getModuleID()));
			}
		}

		if(moduleDescriptors != null){

			List<Integer> enabledSourceModuleIDs = new ArrayList<Integer>(moduleDescriptors.size());

			for(SimpleForegroundModuleDescriptor foregroundModule : moduleDescriptors){

				Integer moduleID = foregroundModule.getAttributeHandler().getInt(CBConstants.MODULE_SOURCE_MODULE_ID_ATTRIBUTE);

				if(moduleID != null){

					enabledSourceModuleIDs.add(moduleID);
				}
			}

			XMLUtils.append(doc, sectionSettingsElement, "EnabledModules", "moduleID", enabledSourceModuleIDs);
		}

		if(validationErrors != null) {

			XMLUtils.append(doc, sectionSettingsElement, "ValidationErrors", validationErrors);
			sectionSettingsElement.appendChild(RequestUtils.getRequestParameters(req, doc));
		}

		return new SimpleForegroundModuleResponse(doc, moduleDescriptor.getName(), getDefaultBreadcrumb());
	}

	@Override
	protected void moduleConfigured() throws Exception {

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

	private SimpleForegroundModuleDescriptor getMatchingModuleDescriptor(Integer moduleID, List<SimpleForegroundModuleDescriptor> moduleDescriptors) {

		for(SimpleForegroundModuleDescriptor moduleDescriptor : moduleDescriptors){

			Integer sourceModuleID = moduleDescriptor.getAttributeHandler().getInt(CBConstants.MODULE_SOURCE_MODULE_ID_ATTRIBUTE);

			if(sourceModuleID != null && sourceModuleID.equals(moduleID)){

				return moduleDescriptor;
			}
		}

		return null;
	}

	private BufferedImage getLogo(HttpServletRequest req, List<ValidationError> validationErrors) throws ValidationException {

		if (!(req instanceof MultipartRequest)) {

			return null;
		}

		MultipartRequest multipartRequest = (MultipartRequest) req;

		if (multipartRequest.getFileCount() > 0 && !StringUtils.isEmpty(multipartRequest.getFile(0).getName())) {

			FileItem file = multipartRequest.getFile(0);

			String lowerCasefileName = file.getName().toLowerCase();

			if (!(lowerCasefileName.endsWith(".png") || lowerCasefileName.endsWith(".jpg") || lowerCasefileName.endsWith(".gif") || lowerCasefileName.endsWith(".bmp"))) {

				validationErrors.add(new ValidationError("InvalidLogoImageFileFormat"));

			} else {

				try {

					BufferedImage image = ImageUtils.getImage(file.get());

					image = ImageUtils.cropAsSquare(image);

					if (image.getWidth() > sectionImageSize || image.getHeight() > sectionImageSize) {

						image = ImageUtils.scale(image, sectionImageSize, sectionImageSize, Image.SCALE_SMOOTH, BufferedImage.TYPE_INT_ARGB);

					}

					return image;

				} catch (Exception e) {

					validationErrors.add(new ValidationError("UnableToParseLogoImage"));
				}

			}
		}

		return null;
	}


	@Override
	public int getRamThreshold() {

		return ramThreshold;
	}

	@Override
	public long getMaxRequestSize() {

		return maxRequestSize;
	}

	@Override
	public String getTempDir() {

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

		String oldName = notification.getNotificationType();
		
		SectionInterface sectionInterface2 = systemInterface.getSectionInterface(notification.getSectionID());
		
		if (sectionInterface2 == null) {

			log.warn("Unable to find section with ID " + sectionInterface2 + " skipping notification " + notification);
			return null;
		}

		String newName = sectionInterface2.getSectionDescriptor().getName();

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

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);

		XMLUtils.appendNewElement(doc, documentElement, "OldName", oldName);
		XMLUtils.appendNewElement(doc, documentElement, "NewName", newName);
		XMLUtils.appendNewElement(doc, documentElement, "SectionID", notification.getSectionID());
		XMLUtils.appendNewElement(doc, documentElement, "Posted", DateUtils.DATE_TIME_FORMATTER.format(notification.getAdded()));

		XMLUtils.appendNewElement(doc, documentElement, "ModuleName", moduleDescriptor.getName());

		if (!notification.isRead()) {

			XMLUtils.appendNewElement(doc, documentElement, "Unread");
		}

		return transformer.createViewFragment(doc);
	}
}
