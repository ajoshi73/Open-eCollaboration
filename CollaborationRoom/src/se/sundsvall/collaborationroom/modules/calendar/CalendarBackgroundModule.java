package se.sundsvall.collaborationroom.modules.calendar;

import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.webutils.http.URIParser;

public class CalendarBackgroundModule extends AnnotatedBackgroundModule {

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Entry<ForegroundModuleDescriptor, CalendarModule> calendarModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(CalendarModule.class);

		if (calendarModuleEntry != null) {

			CalendarModule calendarModule = calendarModuleEntry.getValue();

			Document doc = calendarModule.createDocument(req, uriParser, user);

			Element monthElement = doc.createElement("ShowMiniMonthCalendar");

			doc.getFirstChild().appendChild(monthElement);

			calendarModule.appendCurrentMonthPosts(doc, monthElement, req, user);

			return new SimpleBackgroundModuleResponse(doc);

		}

		return null;
	}

}
