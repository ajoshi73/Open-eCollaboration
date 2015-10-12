package se.sundsvall.collaborationroom.modules.overview;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.modules.favourites.SectionFavouriteProvider;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.modules.util.CBUtilityModule;
import se.dosf.communitybase.utils.CBSectionAttributeHelper;
import se.sundsvall.collaborationroom.modules.members.MembersModule;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.ModuleUtils;
import se.unlogic.hierarchy.core.utils.MultiForegroundModuleTracker;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.collections.MapUtils;
import se.unlogic.standardutils.references.WeakReferenceUtils;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class OverviewBackgroundModule extends AnnotatedBackgroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Members count", description = "The number of members to show in members list")
	private Integer membersCount = 5;

	@InstanceManagerDependency(required = true)
	private CBInterface cbInterface;

	@InstanceManagerDependency(required = false)
	private UserProfileProvider userProfileProvider;

	@InstanceManagerDependency(required = false)
	private SectionFavouriteProvider sectionFavouriteProvider;

	@InstanceManagerDependency(required = false)
	private CBUtilityModule cbUtilityModule;

	private WeakReference<MembersModule> membersModuleReference;

	private Integer sectionID;

	protected MultiForegroundModuleTracker<ShortCutProvider> shortCutProviderTracker;

	@Override
	public void init(BackgroundModuleDescriptor descriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(descriptor, sectionInterface, dataSource);

		sectionID = sectionInterface.getSectionDescriptor().getSectionID();

		shortCutProviderTracker = new MultiForegroundModuleTracker<ShortCutProvider>(ShortCutProvider.class, systemInterface, sectionInterface, false, true);

	}

	@Override
	public void unload() throws Exception {

		shortCutProviderTracker.shutdown();

		super.unload();
	}

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "SectionName", sectionInterface.getSectionDescriptor().getName());
		XMLUtils.appendNewElement(doc, documentElement, "SectionID", sectionInterface.getSectionDescriptor().getSectionID());
		XMLUtils.appendNewElement(doc, documentElement, "SectionURI", req.getContextPath() + sectionInterface.getSectionDescriptor().getFullAlias());
		XMLUtils.appendNewElement(doc, documentElement, "SectionAccessMode", CBSectionAttributeHelper.getAccessMode(sectionInterface.getSectionDescriptor()));
		XMLUtils.appendNewElement(doc, documentElement, "SectionDescription", CBSectionAttributeHelper.getDescription(sectionInterface.getSectionDescriptor()));

		Role memberRole = cbInterface.getRole(sectionID, user);

		if (memberRole != null && memberRole.hasManageMembersAccess()) {
			XMLUtils.appendNewElement(doc, documentElement, "HasManageMemberAccess", true);
		}

		List<Integer> sectionMembers = cbInterface.getSectionMembers(sectionID);

		if (!CollectionUtils.isEmpty(sectionMembers)) {

			List<Integer> randomMembers = new ArrayList<Integer>(membersCount);

			if (sectionMembers.size() > membersCount) {

				Collections.shuffle(sectionMembers);

				randomMembers.addAll(sectionMembers.subList(0, membersCount));

			} else {

				randomMembers.addAll(sectionMembers);
			}

			if (!randomMembers.isEmpty()) {

				List<User> users = systemInterface.getUserHandler().getUsers(randomMembers, false, false);

				XMLUtils.append(doc, documentElement, "RandomMembers", users);
				XMLUtils.appendNewElement(doc, documentElement, "MembersCount", sectionMembers.size());

			}

		} else {

			XMLUtils.appendNewElement(doc, documentElement, "MembersCount", 0);

		}

		if (userProfileProvider != null) {
			XMLUtils.appendNewElement(doc, documentElement, "ProfileImageURI", req.getContextPath() + userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, documentElement, "ShowProfileURI", req.getContextPath() + userProfileProvider.getShowProfileAlias());
		}

		if (cbUtilityModule != null) {
			XMLUtils.appendNewElement(doc, documentElement, "SectionLogoURI", req.getContextPath() + cbUtilityModule.getFullAlias() + "/sectionlogo/" + sectionID + "?" + cbUtilityModule.getSectionLogoLastModified(sectionID));
		}

		if (sectionFavouriteProvider != null) {

			List<Integer> sectionIDs = sectionFavouriteProvider.getUserSectionFavourites(user.getUserID());

			if (sectionIDs != null && sectionIDs.contains(sectionID)) {
				XMLUtils.appendNewElement(doc, documentElement, "IsFavourite", true);
			}
			XMLUtils.appendNewElement(doc, documentElement, "ToggleFavouriteURI", req.getContextPath() + sectionFavouriteProvider.getToggleFavouriteAlias());
		}

		MembersModule membersModule;

		if ((membersModule = getMembersModule()) != null) {

			XMLUtils.appendNewElement(doc, documentElement, "MembersModuleURI", req.getContextPath() + membersModule.getFullAlias());

			Integer followRoleID = membersModule.getFollowRoleID();

			if (followRoleID != null && cbInterface.getSectionRole(sectionID, followRoleID) != null) {

				if (memberRole == null) {

					XMLUtils.appendNewElement(doc, documentElement, "followRoleID", true);

				} else if (memberRole.getRoleID().equals(followRoleID)) {

					XMLUtils.appendNewElement(doc, documentElement, "followRoleID", true);
					XMLUtils.appendNewElement(doc, documentElement, "isFollower", true);
				}

			}

		}

		return new SimpleBackgroundModuleResponse(doc);

	}

	protected MembersModule getMembersModule() {

		MembersModule membersModule = WeakReferenceUtils.getReferenceValue(this.membersModuleReference);

		if (membersModule != null) {

			return membersModule;
		}

		membersModule = MapUtils.getEntryValue(ModuleUtils.findForegroundModule(MembersModule.class, true, null, false, sectionInterface));

		if (membersModule != null) {

			this.membersModuleReference = new WeakReference<MembersModule>(membersModule);

		} else {

			this.membersModuleReference = null;
		}

		return membersModule;

	}

}
