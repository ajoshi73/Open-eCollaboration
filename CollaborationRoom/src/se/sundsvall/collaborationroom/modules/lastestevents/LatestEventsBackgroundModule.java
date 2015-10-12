package se.sundsvall.collaborationroom.modules.lastestevents;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.enums.EventFormat;
import se.dosf.communitybase.modules.sectionevents.CBSectionEventHandler;
import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;


public class LatestEventsBackgroundModule extends AnnotatedBackgroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name="Event count", description="The number of events to display", formatValidator=PositiveStringIntegerValidator.class)
	private int eventCount = 3;

	@ModuleSetting
	@TextFieldSettingDescriptor(name="Connector alias", description="The alias of the connector module relative to this section")
	private String connectorModuleAlias;

	@InstanceManagerDependency(required=true)
	private CBSectionEventHandler sectionEventHandler;

	private Integer sectionID;

	@Override
	public void init(BackgroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		sectionID = sectionInterface.getSectionDescriptor().getSectionID();
	}

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();

		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		if(connectorModuleAlias != null){

			XMLUtils.appendNewElement(doc, documentElement, "ConnectorURL", req.getContextPath() + sectionInterface.getSectionDescriptor().getFullAlias() + "/" + connectorModuleAlias);
		}

		List<SectionEvent> events = sectionEventHandler.getEvents(sectionID, 0, eventCount);

		if(events != null){

			String fullContextPath = RequestUtils.getFullContextPathURL(req);

			Element eventsElement = doc.createElement("Events");
			documentElement.appendChild(eventsElement);

			for(SectionEvent event : events){

				try{
					eventsElement.appendChild(event.getFragment(fullContextPath, EventFormat.LARGE).toXML(doc));

				}catch(Exception e){

					log.error("Error getting large fragment from event " + event + " originating from moduleID " + event.getModuleID() + " in sectionID " + sectionInterface.getSectionDescriptor().getSectionID(), e);
				}
			}
		}

		return new SimpleBackgroundModuleResponse(doc);
	}
}
