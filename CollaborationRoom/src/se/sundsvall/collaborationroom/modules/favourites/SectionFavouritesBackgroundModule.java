package se.sundsvall.collaborationroom.modules.favourites;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.modules.favourites.SectionFavouriteProvider;
import se.dosf.communitybase.modules.util.CBUtilityModule;
import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class SectionFavouritesBackgroundModule extends AnnotatedBackgroundModule {

	@InstanceManagerDependency(required = true)
	protected CBInterface cbInterface;

	@InstanceManagerDependency(required = false)
	private CBUtilityModule cbUtilityModule;

	@InstanceManagerDependency(required = true)
	private SectionFavouriteProvider sectionFavouriteProvider;

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "moduleName", moduleDescriptor.getName());
		XMLUtils.appendNewElement(doc, documentElement, "contextPath", req.getContextPath());
		
		if(cbUtilityModule != null) {
			XMLUtils.appendNewElement(doc, documentElement, "CBUtilityModuleAlias", cbUtilityModule.getFullAlias());
		}
		
		List<Integer> favouriteSectionIDs = sectionFavouriteProvider.getUserSectionFavourites(user.getUserID());

		if (favouriteSectionIDs != null) {

			for (Integer favouriteSectionID : favouriteSectionIDs) {

				SectionInterface sectionInterface = systemInterface.getSectionInterface(favouriteSectionID);

				if (sectionInterface != null) {

					Element sectionElement = sectionInterface.getSectionDescriptor().toXML(doc);

					List<Integer> members = cbInterface.getSectionMembers(sectionInterface.getSectionDescriptor().getSectionID());

					XMLUtils.appendNewElement(doc, sectionElement, "membersCount", !CollectionUtils.isEmpty(members) ? members.size() : 0);

					documentElement.appendChild(sectionElement);

				}
			}

		}

		return new SimpleBackgroundModuleResponse(doc);
	}

}
