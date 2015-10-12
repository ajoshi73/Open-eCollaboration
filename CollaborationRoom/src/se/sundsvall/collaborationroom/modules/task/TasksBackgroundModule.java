package se.sundsvall.collaborationroom.modules.task;

import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class TasksBackgroundModule extends AnnotatedBackgroundModule {

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Entry<ForegroundModuleDescriptor, TaskModule> taskModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(TaskModule.class);

		if (taskModuleEntry != null) {

			TaskModule taskModule = taskModuleEntry.getValue();

			Document doc = XMLUtils.createDomDocument();
			
			Element documentElement = doc.createElement("Document");
			doc.appendChild(documentElement);

			XMLUtils.appendNewElement(doc, documentElement, "moduleName", moduleDescriptor.getName());
			XMLUtils.appendNewElement(doc, documentElement, "tasksModuleAlias", req.getContextPath() + taskModule.getFullAlias());
			documentElement.appendChild(user.toXML(doc));
			
			Element tasksElement = doc.createElement("ListTasks");

			doc.getFirstChild().appendChild(tasksElement);

			taskModule.appendAdditionalTasks(doc, tasksElement, 0);
			
			return new SimpleBackgroundModuleResponse(doc);

		}

		return null;
	}

}
