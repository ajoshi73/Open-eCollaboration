package se.sundsvall.collaborationroom.modules.calendar;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.webutils.http.URIParser;

public class UserCalendarBackgroundModule extends AnnotatedBackgroundModule {

	@InstanceManagerDependency(required = true)
	private UserCalendarModule userCalendarModule;

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = userCalendarModule.createDocument(req, uriParser, user);

		Element monthElement = doc.createElement("ShowMiniMonthCalendar");

		doc.getFirstChild().appendChild(monthElement);

		userCalendarModule.appendCurrentMonthPosts(doc, monthElement, req, user);

		return new SimpleBackgroundModuleResponse(doc);

	}

}
