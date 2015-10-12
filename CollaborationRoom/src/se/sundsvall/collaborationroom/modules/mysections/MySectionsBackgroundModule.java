package se.sundsvall.collaborationroom.modules.mysections;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.modules.favourites.SectionFavouriteProvider;
import se.dosf.communitybase.modules.util.CBUtilityModule;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionDescriptor;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class MySectionsBackgroundModule extends AnnotatedBackgroundModule {

	@InstanceManagerDependency(required = true)
	protected CBInterface cbInterface;

	@InstanceManagerDependency(required = true)
	private SectionFavouriteProvider sectionFavouriteProvider;

	@InstanceManagerDependency(required = false)
	private CBUtilityModule cbUtilityModule;
	
	@InstanceManagerDependency(required = false)
	private MySectionsModule mySectionsModule;
	
	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "contextPath", req.getContextPath());
		
		if (sectionFavouriteProvider != null) {

			List<Integer> favouriteSectionIDs = sectionFavouriteProvider.getUserSectionFavourites(user.getUserID());

			appendSections(doc, documentElement, "FavouriteSection", favouriteSectionIDs);

		}
		
		if(!CBAccessUtils.isExternalUser(user) && mySectionsModule != null) {
			
			XMLUtils.appendNewElement(doc, documentElement, "mySectionsModuleAlias", mySectionsModule.getFullAlias());
			
		}

		appendSections(doc, documentElement, "MemberSection", CBAccessUtils.getUserSections(user));
		
		return new SimpleBackgroundModuleResponse(doc);
	}

	private void appendSections(Document doc, Element element, String elementName, List<Integer> sectionIDs) {

		if (sectionIDs != null) {

			for (Integer sectionID : sectionIDs) {

				Element sectionElement = doc.createElement(elementName);
				
				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

				if (sectionInterface != null) {

					SectionDescriptor sectionDescriptor = sectionInterface.getSectionDescriptor();

					XMLUtils.appendNewElement(doc, sectionElement, "sectionID", sectionID);
					XMLUtils.appendNewElement(doc, sectionElement, "name", sectionDescriptor.getName());
					XMLUtils.appendNewElement(doc, sectionElement, "fullAlias", sectionDescriptor.getFullAlias());

				}
				
				if(sectionElement.hasChildNodes()){
					
					element.appendChild(sectionElement);
				}
			}
		}
	}
}
