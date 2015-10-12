package se.sundsvall.collaborationroom.modules.members;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.CBConstants;
import se.dosf.communitybase.enums.NotificationFormat;
import se.dosf.communitybase.enums.SectionAccessMode;
import se.dosf.communitybase.events.CBMemberRemovedEvent;
import se.dosf.communitybase.events.CBSectionAccessModeChangedEvent;
import se.dosf.communitybase.interfaces.Notification;
import se.dosf.communitybase.interfaces.NotificationHandler;
import se.dosf.communitybase.interfaces.NotificationTransformer;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.invitation.InvitationModule;
import se.dosf.communitybase.modules.invitation.beans.Invitation;
import se.dosf.communitybase.modules.invitation.beans.SectionInvitation;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBSectionAttributeHelper;
import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.unlogic.emailutils.framework.EmailUtils;
import se.unlogic.hierarchy.core.annotations.EventListener;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.annotations.XSLVariable;
import se.unlogic.hierarchy.core.beans.Group;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.SimpleSectionDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventSource;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.enums.UserField;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.UserUtils;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.enums.Order;
import se.unlogic.standardutils.json.JsonArray;
import se.unlogic.standardutils.json.JsonObject;
import se.unlogic.standardutils.json.JsonUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.HTTPUtils;
import se.unlogic.webutils.http.URIParser;

public class MembersModule extends CBBaseModule implements NotificationTransformer, ShortCutProvider {

	private static final Comparator<User> USER_COMPARATOR = UserField.FIRSTNAME.getComparator(Order.ASC);

	private static final String USER_ADDED_TO_SECTION_NOTIFICATION_TYPE = "addedToSection";
	private static final String USER_ROLE_CHANGED_NOTIFICATION_TYPE = "roleChanged";
	private static final String USER_DELETED_FROM_SECTION_NOTIFICATION_TYPE = "removedFromSection";

	@XSLVariable(prefix = "java.")
	private String shortCutText = "Invite members";

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Follow role id", description = "The role id that sholud be set when user choosing to follow a section", required = true, formatValidator = PositiveStringIntegerValidator.class)
	private Integer followRoleID;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Group filter attribute", description = "Only groups that have an attribute of this name set will be returned when searching for groups. If not attribute is set all groups will be searchable.")
	private String groupFilterAttribute;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Notification stylesheet", description = "The stylesheet used to transform notifications")
	private String notificationStylesheet = "MemberNotification.sv.xsl";

	@ModuleSetting
	@TextFieldSettingDescriptor(name="Max search hits", description="The maximum number of users and groups hits to return when searching (no value means unlimited).")
	private Integer maxSearchHits;

	@InstanceManagerDependency(required = true)
	private InvitationModule invitationModule;

	@InstanceManagerDependency(required = false)
	UserProfileProvider userProfileProvider;

	@InstanceManagerDependency(required = false)
	protected NotificationHandler notificationHandler;

	private SimpleViewFragmentTransformer notificationFragmentTransformer;

	private Integer sourceModuleID;

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

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		log.info("User " + user + " listing members in section " + sectionInterface.getSectionDescriptor());

		Document doc = createDocument(req, uriParser, user);

		if (userProfileProvider != null) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		Role userRole = cbInterface.getRole(getSectionID(), user);

		if (userRole != null && userRole.hasManageMembersAccess()) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "hasManageAccess", true);
		}

		Element listElement = doc.createElement("ListMembers");

		doc.getFirstChild().appendChild(listElement);

		List<Role> roles = cbInterface.getRoles(getSectionID());

		if (roles != null) {

			Element allowedRoles = doc.createElement("AllowedRoles");
			listElement.appendChild(allowedRoles);

			List<Integer> sectionMembers = cbInterface.getSectionMembers(getSectionID());

			Element membersElement = doc.createElement("Members");
			listElement.appendChild(membersElement);

			if (!CollectionUtils.isEmpty(sectionMembers)) {

				List<User> memberUsers = systemInterface.getUserHandler().getUsers(sectionMembers, true, true);

				if (memberUsers != null) {

					Collections.sort(memberUsers, USER_COMPARATOR);
					UserUtils.appendUsers(doc, membersElement, memberUsers, true);

				}

			}

			for (Role role : roles) {

				Group group = cbInterface.getGroup(role.getRoleID(), getSectionID(), true);

				if (group != null) {

					Element roleElement = role.toXML(doc);

					roleElement.appendChild(group.toXML(doc));
					allowedRoles.appendChild(roleElement);

				}

			}

		}

		XMLUtils.append(doc, listElement, "Invitations", invitationModule.getInvitations(getSectionID()));

		return new SimpleForegroundModuleResponse(doc, this.getDefaultBreadcrumb());

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateRole(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		Integer userID = uriParser.getInt(2);
		Integer roleID = uriParser.getInt(3);

		if (userID != null && roleID != null) {

			JsonObject jsonObject = new JsonObject(1);

			if (validateSectionMemberRoles(roleID, userID)) {

				if (cbInterface.setUserRole(userID, getSectionID(), roleID)) {

					log.info("User " + user + " updated role to role " + roleID + " for userID " + userID);

					jsonObject.putField("UpdateSuccess", "true");

					if (notificationHandler != null && !user.getUserID().equals(userID)) {

						try {
							notificationHandler.addNotification(userID, moduleDescriptor.getSectionID(), sourceModuleID, USER_ROLE_CHANGED_NOTIFICATION_TYPE, user.getUserID(), null);

						} catch (Exception e) {

							log.error("Error adding notification for user ID " + userID, e);
						}
					}

				} else {

					jsonObject.putField("UnableToUpdateRole", "true");

				}

			} else {

				jsonObject.putField("NoManageMemberRole", "true");
			}

			HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

			return null;

		}

		throw new URINotFoundException(uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteMember(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer userID = uriParser.getInt(2);

		if (userID != null) {

			boolean selfDelete = user.getUserID().equals(userID);

			if (!hasManageMemberAccess(user) && !selfDelete) {

				throw new AccessDeniedException("Manager members denied in section " + sectionInterface.getSectionDescriptor());
			}

			JsonObject jsonObject = new JsonObject(1);

			if (validateSectionMemberRoles(null, userID)) {

				boolean success = false;

				if (selfDelete) {

					success = cbInterface.removeUser(user, getSectionID());

				} else {

					success = cbInterface.removeUser(userID, getSectionID());

				}

				if (success) {

					log.info("User " + user + " removed user from section room " + sectionInterface.getSectionDescriptor());

					jsonObject.putField("DeleteSuccess", "true");

					if (selfDelete) {

						SectionAccessMode accessMode = CBSectionAttributeHelper.getAccessMode(getSectionDescriptor());

						if (accessMode != null && accessMode.equals(SectionAccessMode.OPEN)) {

							jsonObject.putField("RedirectUser", getModuleURI(req));

						} else {

							jsonObject.putField("RedirectUser", req.getContextPath() + "/");
						}

					}

					if (notificationHandler != null && !selfDelete) {

						try {
							notificationHandler.addNotification(userID, moduleDescriptor.getSectionID(), sourceModuleID, USER_DELETED_FROM_SECTION_NOTIFICATION_TYPE, user.getUserID(), null);

						} catch (Exception e) {

							log.error("Error adding notification for user ID " + userID, e);
						}
					}

				} else {

					jsonObject.putField("UnableToDeleteMember", "true");

				}

			} else {

				jsonObject.putField("NoManageMemberRole", "true");
			}

			HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

			return null;

		}

		throw new URINotFoundException(uriParser);

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse searchUser(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		String query = req.getParameter("q");

		JsonObject response = new JsonObject(2);

		int hitCount = 0;

		if (!StringUtils.isEmpty(query)) {

			List<User> users = systemInterface.getUserHandler().searchUsers(query, false, true, maxSearchHits);

			log.info("User " + user + " searching for users using query " + query + ", found " + CollectionUtils.getSize(users) + " hits");

			if (users != null) {

				JsonArray usersJson = new JsonArray();

				for (User currentUser : users) {

					JsonObject userJson = new JsonObject(3);
					userJson.putField("userID", currentUser.getUserID().toString());
					userJson.putField("fullName", getFullName(currentUser));
					userJson.putField("email", currentUser.getEmail());

					usersJson.addNode(userJson);
				}

				response.putField("hits", usersJson);

				hitCount = usersJson.size();
			}

		}

		response.putField("hitCount", hitCount);

		HTTPUtils.sendReponse(response.toJson(), JsonUtils.getContentType(), res);

		return null;

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse searchGroup(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		String query = req.getParameter("q");

		JsonObject response = new JsonObject(2);

		int hitCount = 0;

		if (!StringUtils.isEmpty(query)) {

			List<Group> groups;

			if(groupFilterAttribute != null){

				groups = systemInterface.getGroupHandler().searchGroupsWithAttribute(query, false, groupFilterAttribute, maxSearchHits);

			}else{

				groups = systemInterface.getGroupHandler().searchGroups(query, false, maxSearchHits);
			}

			log.info("User " + user + " searching for groups using query " + query + ", found " + CollectionUtils.getSize(groups) + " hits");

			if (groups != null) {

				JsonArray jsonArray = new JsonArray();

				for (Group group : groups) {

					JsonObject jsonObject = new JsonObject(3);
					jsonObject.putField("groupID", group.getGroupID());
					jsonObject.putField("name", group.getName());
					jsonObject.putField("userCount", systemInterface.getUserHandler().getUserCountByGroup(group.getGroupID()));

					jsonArray.addNode(jsonObject);
				}

				response.putField("hits", jsonArray);

				hitCount = jsonArray.size();

			}

		}

		response.putField("hitCount", hitCount);

		HTTPUtils.sendReponse(response.toJson(), JsonUtils.getContentType(), res);

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse getGroupUsers(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		Integer groupID = NumberUtils.toInt(req.getParameter("g"));

		JsonObject response = new JsonObject(2);

		int hitCount = 0;

		if (groupID != null) {

			Group group = systemInterface.getGroupHandler().getGroup(groupID, true);

			if(group != null && (groupFilterAttribute == null || (group.getAttributeHandler() != null || group.getAttributeHandler().getString(groupFilterAttribute) != null))){

				List<User> users = systemInterface.getUserHandler().getUsersByGroup(groupID, false, true);

				log.info("User " + user + " gettings users in group " + group + ", found " + CollectionUtils.getSize(users) + " hits");

				if (users != null) {

					JsonArray usersJson = new JsonArray();

					for (User currentUser : users) {

						JsonObject userJson = new JsonObject(3);
						userJson.putField("userID", currentUser.getUserID().toString());
						userJson.putField("fullName", getFullName(currentUser));
						userJson.putField("email", currentUser.getEmail());

						usersJson.addNode(userJson);
					}

					response.putField("hits", usersJson);

					hitCount = usersJson.size();
				}
			}
		}

		response.putField("hitCount", hitCount);

		HTTPUtils.sendReponse(response.toJson(), JsonUtils.getContentType(), res);

		return null;
	}

	private String getFullName(User currentUser) {

		String organisationAttribute = UserUtils.getAttribute("organization", currentUser);

		if (organisationAttribute != null) {

			return currentUser.getFirstname() + " " + currentUser.getLastname() + " (" + organisationAttribute + ")";
		}

		return currentUser.getFirstname() + " " + currentUser.getLastname();
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addMember(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		if (req.getMethod().equalsIgnoreCase("POST")) {

			List<Integer> userIDs = NumberUtils.toInt(req.getParameterValues("userID"));

			if (userIDs != null) {

				for (Integer userID : userIDs) {

					Integer roleID = NumberUtils.toInt(req.getParameter("role_" + userID));

					if (roleID != null) {

						boolean success = false;

						if (user.getUserID().equals(userID)) {

							success = cbInterface.setUserRole(user, getSectionID(), roleID);
						} else {
							success = cbInterface.setUserRole(userID, getSectionID(), roleID);
						}

						if (success) {

							log.info("User " + user + " added userID " + userID + " to section room " + sectionInterface.getSectionDescriptor());

							if (notificationHandler != null && !user.getUserID().equals(userID)) {

								try {
									notificationHandler.addNotification(userID, moduleDescriptor.getSectionID(), sourceModuleID, USER_ADDED_TO_SECTION_NOTIFICATION_TYPE, user.getUserID(), null);

								} catch (Exception e) {

									log.error("Error adding notification for user ID " + userID, e);
								}
							}
						}
					}
				}
			}
		}

		redirectToDefaultMethod(req, res, "members");

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse addInvitations(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		if (req.getMethod().equalsIgnoreCase("POST")) {

			String[] emails = req.getParameterValues("email");

			if (emails != null) {

				for (String email : emails) {

					if (EmailUtils.isValidEmailAddress(email)) {

						Integer roleID = NumberUtils.toInt(req.getParameter("role_" + email));

						if (roleID != null) {

							User currentUser = systemInterface.getUserHandler().getUserByEmail(email, true, false);

							if (currentUser != null) {

								log.info("User " + user + " adding existing user " + currentUser + " to section room " + sectionInterface.getSectionDescriptor() + " with role " + roleID);

								Role currentRole = cbInterface.getRole(getSectionID(), currentUser);

								if (currentRole == null) {

									Integer userID = currentUser.getUserID();

									if (cbInterface.setUserRole(userID, getSectionID(), roleID)) {

										if (notificationHandler != null && !user.getUserID().equals(userID)) {

											try {

												notificationHandler.addNotification(userID, moduleDescriptor.getSectionID(), sourceModuleID, USER_ADDED_TO_SECTION_NOTIFICATION_TYPE, user.getUserID(), null);

											} catch (Exception e) {

												log.error("Error adding notification for user ID " + userID, e);
											}
										}

									}
								}

							} else {

								log.info("User " + user + " inviting email " + email + " to section room " + sectionInterface.getSectionDescriptor() + " with role " + roleID);

								if (!invitationModule.addInvitation(req, email, getSectionID(), roleID, true)) {

									log.warn("Unable to invite " + email + " to section " + getSectionID() + " with role " + roleID);
								}

							}

						}

					}

				}

			}

		}

		redirectToDefaultMethod(req, res, "invitations");

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse updateInvitationRole(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		Integer invitationID = uriParser.getInt(2);
		Integer roleID = uriParser.getInt(3);

		if (invitationID != null && roleID != null) {

			JsonObject jsonObject = new JsonObject(1);

			if (invitationModule.updateInvitation(invitationID, getSectionID(), roleID)) {

				log.info("User " + user + " updated role to role " + roleID + " for invitationID " + invitationID);

				jsonObject.putField("UpdateSuccess", "true");

			} else {

				jsonObject.putField("UnableToUpdateRole", "true");

			}

			HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

			return null;

		}

		throw new URINotFoundException(uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse deleteInvitation(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		Integer invitationID = uriParser.getInt(2);

		if (invitationID != null) {

			JsonObject jsonObject = new JsonObject(1);

			if (invitationModule.removeInvitation(invitationID, getSectionID())) {

				log.info("User " + user + " removed invitation " + invitationID + " from section room " + sectionInterface.getSectionDescriptor());

				jsonObject.putField("DeleteSuccess", "true");

			} else {

				jsonObject.putField("UnableToDeleteInvitation", "true");

			}

			HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

			return null;

		}

		throw new URINotFoundException(uriParser);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse resendInvitation(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		Integer invitationID = uriParser.getInt(2);

		Invitation invitation = null;

		if (invitationID != null && (invitation = invitationModule.getInvitation(invitationID)) != null) {

			JsonObject jsonObject = new JsonObject(1);

			if (invitationModule.sendInvitation(invitation, req)) {

				log.info("User " + user + " resent invitation " + invitationID + " for section room " + sectionInterface.getSectionDescriptor());

				JsonObject invitationJson = new JsonObject();
				invitationJson.putField("lastSent", DateUtils.DATE_TIME_FORMATTER.format(invitation.getLastSent()));
				invitationJson.putField("sendCount", invitation.getSendCount());

				jsonObject.putField("SendSuccess", invitationJson);

			} else {

				jsonObject.putField("UnableToSendInvitation", "true");

			}

			HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

			return null;

		}

		throw new URINotFoundException(uriParser);

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse checkEmail(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkManageMemberAccess(user);

		String email = req.getParameter("email");

		JsonObject jsonObject = new JsonObject(1);

		if (email != null && EmailUtils.isValidEmailAddress(email)) {

			User existingUser = systemInterface.getUserHandler().getUserByEmail(email, true, false);

			if (existingUser != null) {

				JsonObject userJson = new JsonObject(1);

				userJson.putField("userID", existingUser.getUserID());
				userJson.putField("fullName", existingUser.getFirstname() + " " + existingUser.getLastname());

				Role role = cbInterface.getRole(getSectionID(), existingUser);

				if (role != null) {
					JsonObject roleJson = new JsonObject(2);
					roleJson.putField("roleID", role.getRoleID());
					roleJson.putField("name", role.getName());
					userJson.putField("Role", roleJson);
				}

				jsonObject.putField("ExistingUser", userJson);

			} else {

				Invitation invitation = invitationModule.getInvitation(email);

				if (invitation != null) {

					JsonObject invitationJson = new JsonObject(1);

					invitationJson.putField("email", email);

					List<SectionInvitation> sectionInvitations = invitation.getSectionInvitations();

					if (sectionInvitations != null) {

						for (SectionInvitation sectionInvitation : sectionInvitations) {

							if (sectionInvitation.getSectionID().equals(getSectionID())) {

								Role role = cbInterface.getSectionRole(getSectionID(), sectionInvitation.getRoleID());

								if (role != null) {
									JsonObject roleJson = new JsonObject(2);
									roleJson.putField("roleID", role.getRoleID());
									roleJson.putField("name", role.getName());
									invitationJson.putField("Role", roleJson);
								}

								break;
							}

						}

					}

					jsonObject.putField("ExistingInvitation", invitationJson);

				}

			}

		}

		HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

		return null;
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse togglefollow(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		SectionAccessMode accessMode = CBSectionAttributeHelper.getAccessMode(getSectionDescriptor());

		if (followRoleID != null && accessMode != null && accessMode.equals(SectionAccessMode.OPEN)) {

			Role currentRole = cbInterface.getRole(getSectionID(), user);

			JsonObject jsonObject = new JsonObject(1);

			if (currentRole == null) {

				if (cbInterface.setUserRole(user, getSectionID(), followRoleID)) {

					log.info("User " + user + " added it self as follower in section " + sectionInterface.getSectionDescriptor());

					jsonObject.putField("AddSuccess", true);

				} else {

					jsonObject.putField("UnableToAddRole", true);

				}

			} else if (currentRole.getRoleID().equals(followRoleID)) {

				if (cbInterface.removeUser(user, getSectionID())) {

					log.info("User " + user + " removing it self as follower in section " + sectionInterface.getSectionDescriptor());

					jsonObject.putField("DeleteSuccess", true);

				} else {

					jsonObject.putField("UnableToDeleteRole", true);

				}
			}

			HTTPUtils.sendReponse(jsonObject.toJson(), JsonUtils.getContentType(), res);

		}

		throw new AccessDeniedException("Follow is not allowed in this section");

	}

	private boolean validateSectionMemberRoles(Integer newRoleID, Integer userID) {

		List<Integer> sectionMembers = cbInterface.getSectionMembers(getSectionID());

		if (newRoleID != null) {

			Role newRole = cbInterface.getSectionRole(getSectionID(), newRoleID);

			if (newRole != null && newRole.hasManageMembersAccess()) {

				return true;
			}

		}

		if (sectionMembers != null && sectionMembers.size() > 1) {

			sectionMembers.remove(userID);

			List<User> users = systemInterface.getUserHandler().getUsers(sectionMembers, true, true);

			for (User user : users) {

				Role role = cbInterface.getRole(getSectionID(), user);

				if (role != null && role.hasManageMembersAccess()) {

					return true;
				}

			}

		}

		return false;
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

	public Integer getFollowRoleID() {

		return followRoleID;
	}

	public void checkManageMemberAccess(User user) throws AccessDeniedException {

		Role role = cbInterface.getRole(getSectionID(), user);

		if (role != null && !role.hasManageMembersAccess()) {

			throw new AccessDeniedException("Manager members denied in section " + sectionInterface.getSectionDescriptor());
		}

	}

	public boolean hasManageMemberAccess(User user) {

		Role role = cbInterface.getRole(getSectionID(), user);

		if (role != null && role.hasManageMembersAccess()) {

			return true;
		}

		return false;
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

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		XMLUtils.appendNewElement(doc, documentElement, "Type", notification.getNotificationType());
		XMLUtils.appendNewElement(doc, documentElement, "Added", DateUtils.DATE_TIME_FORMATTER.format(notification.getAdded()));

		XMLUtils.append(doc, documentElement, systemInterface.getUserHandler().getUser(notification.getExternalNotificationID(), false, false));

		if (userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "SectionName", sectionInterface.getSectionDescriptor().getName());
		XMLUtils.appendNewElement(doc, documentElement, "ModuleName", moduleDescriptor.getName());

		XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);
		XMLUtils.appendNewElement(doc, documentElement, "ModuleURL", fullContextPath + this.getFullAlias());

		if (!notification.isRead()) {

			XMLUtils.appendNewElement(doc, documentElement, "Unread");
		}

		return transformer.createViewFragment(doc);
	}

	@Override
	public List<ShortCut> getShortCuts(User user) {

		Role role = cbInterface.getRole(getSectionID(), user);

		if (role != null && role.hasManageMembersAccess()) {

			return Collections.singletonList(new ShortCut(shortCutText, shortCutText, this.getFullAlias() + "#invite"));
		}

		return null;
	}

	@EventListener(channel = SimpleSectionDescriptor.class)
	public void processEvent(CBSectionAccessModeChangedEvent event, EventSource source) {

		if (getSectionID().equals(event.getSectionID()) && followRoleID != null && SectionAccessMode.OPEN.equals(event.getPreviousAccessMode())) {

			List<Integer> memberIDs = cbInterface.getSectionMembers(getSectionID());

			if (!CollectionUtils.isEmpty(memberIDs)) {

				List<User> users = systemInterface.getUserHandler().getUsers(memberIDs, true, true);

				if (!CollectionUtils.isEmpty(users)) {

					for (User user : users) {

						Role currentRole = cbInterface.getRole(getSectionID(), user);

						if (currentRole != null && currentRole.getRoleID().equals(followRoleID)) {

							if (cbInterface.removeUser(user, getSectionID())) {

								log.info("User " + user + " follower membership removed from section " + sectionInterface.getSectionDescriptor());

								this.systemInterface.getEventHandler().sendEvent(SimpleSectionDescriptor.class, new CBMemberRemovedEvent(user.getUserID(), event.getSectionID(), event.getCurrentAccessMode()), EventTarget.ALL);
							}
						}
					}
				}
			}
		}
	}

}
