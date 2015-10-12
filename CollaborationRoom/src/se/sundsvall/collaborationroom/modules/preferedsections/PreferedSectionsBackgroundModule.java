package se.sundsvall.collaborationroom.modules.preferedsections;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.enums.EventFormat;
import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.modules.sectionevents.CBSectionEventHandler;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.preferedsections.beans.PreferedSection;
import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;

public class PreferedSectionsBackgroundModule extends AnnotatedBackgroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Event count", description = "The number of events to display", formatValidator = PositiveStringIntegerValidator.class, required = true)
	private int eventCount = 3;
	
	@InstanceManagerDependency(required = true)
	private PreferedSectionsConnectorModule preferedSectionsModule;

	@InstanceManagerDependency(required = true)
	private CBSectionEventHandler cbSectionEvenetHandler;

	@InstanceManagerDependency(required = true)
	private CBInterface cbInterface;

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "contextPath", req.getContextPath());
		XMLUtils.appendNewElement(doc, documentElement, "preferedSectionsConnector", preferedSectionsModule.getFullAlias());
		XMLUtils.appendNewElement(doc, documentElement, "maxPreferedSections", preferedSectionsModule.getMaxPreferedSections());
		
		Element memberSectionsElement = XMLUtils.appendNewElement(doc, documentElement, "MemberSections");
		
		List<Integer> sectionIDs = CBAccessUtils.getUserSections(user);
		
		if(sectionIDs != null) {
		
			List<Integer> preferedSectionIDs = new ArrayList<Integer>(sectionIDs.size());
			
			List<PreferedSection> preferedSections = preferedSectionsModule.getPreferedSections(user);
	
			if (preferedSections != null) {
				
				Element preferedSectionsElement = XMLUtils.appendNewElement(doc, documentElement, "PreferedSections");
				
				for (PreferedSection preferedSection : preferedSections) {
	
					Integer sectionID = preferedSection.getSectionID();
					
					preferedSectionIDs.add(sectionID);
					
					if(!sectionIDs.contains(sectionID)) {
						
						preferedSectionsModule.delete(preferedSection);
						
						continue;
					}
					
					Element sectionElement = appendSection(doc, preferedSectionsElement, sectionID);
	
					if (sectionElement != null) {
	
						XMLUtils.appendNewElement(doc, sectionElement, "membersCount", CollectionUtils.getSize(cbInterface.getSectionMembers(sectionID)));
						XMLUtils.appendNewElement(doc, sectionElement, "eventCount", cbSectionEvenetHandler.getEventsCount(sectionID));
	
						List<SectionEvent> latestEvents = cbSectionEvenetHandler.getEvents(sectionID, 0, eventCount);
	
						if (latestEvents != null) {
	
							String fullContextPath = RequestUtils.getFullContextPathURL(req);
							
							Element eventsElement = doc.createElement("LatestEvents");
							sectionElement.appendChild(eventsElement);
	
							for (SectionEvent event : latestEvents) {
	
								try {
	
									eventsElement.appendChild(event.getFragment(fullContextPath, EventFormat.SMALL).toXML(doc));
	
								} catch (Exception e) {
	
									log.error("Error getting small fragment from event " + event + " originating from moduleID " + event.getModuleID() + " in sectionID " + sectionID, e);
								}
								
							}
							
						}
	
					}
	
				}
				
			}
			
			sectionIDs.removeAll(preferedSectionIDs);
			
			if(!CollectionUtils.isEmpty(sectionIDs)) {
			
				appendSections(doc, memberSectionsElement, sectionIDs);
			
			}
		
		}

		return new SimpleBackgroundModuleResponse(doc);
	}

	private Element appendSection(Document doc, Element element, Integer sectionID) throws SQLException {

		SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

		if (sectionInterface != null) {

			Element sectionElement = sectionInterface.getSectionDescriptor().toXML(doc);
			element.appendChild(sectionElement);

			return sectionElement;
		}
			
		return null;
	}

	private void appendSections(Document doc, Element element, List<Integer> sectionIDs) throws SQLException {

		if (sectionIDs != null) {

			for (Integer sectionID : sectionIDs) {

				appendSection(doc, element, sectionID);

			}

		}

	}

}
