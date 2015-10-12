package se.sundsvall.collaborationroom.modules.lastestevents;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.enums.EventFormat;
import se.dosf.communitybase.modules.sectionevents.CBSectionEventHandler;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.foregroundmodules.AnnotatedForegroundModule;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.validation.PositiveStringIntegerValidator;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;


public class LatestEventsConnectorModule extends AnnotatedForegroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name="Event fetch count", description="The number of events to send in each request", formatValidator=PositiveStringIntegerValidator.class)
	private int eventCount = 3;

	@InstanceManagerDependency(required=true)
	private CBSectionEventHandler sectionEventHandler;

	private Integer sectionID;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		sectionID = sectionInterface.getSectionDescriptor().getSectionID();
	}

	@Override
	protected ForegroundModuleResponse processForegroundRequest(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		Integer startIndex = NumberUtils.toInt(req.getParameter("startindex"));

		res.setContentType("text/html");

		if(startIndex != null && startIndex >= 0){

			List<SectionEvent> events = sectionEventHandler.getEvents(sectionID, startIndex, eventCount);

			if(events == null){

				res.getWriter().print("");

			}else{

				String fullContextPath = RequestUtils.getFullContextPathURL(req);

				StringBuilder stringBuilder = new StringBuilder();

				for(SectionEvent event : events){

					try{
						stringBuilder.append(event.getFragment(fullContextPath, EventFormat.LARGE).getHTML());

					}catch(Exception e){

						log.error("Error getting large fragment from event " + event + " originating from moduleID " + event.getModuleID() + " in sectionID " + sectionInterface.getSectionDescriptor().getSectionID(), e);
					}
				}

				res.getWriter().print(stringBuilder.toString());
			}

			log.info("User " + user + " requested events starting at index " + startIndex + ", found " + CollectionUtils.getSize(events));

		}else{

			log.warn("User " + user + " requested events starting with invalid start index");

			res.getWriter().print("");
		}

		res.getWriter().flush();

		return null;
	}
}
