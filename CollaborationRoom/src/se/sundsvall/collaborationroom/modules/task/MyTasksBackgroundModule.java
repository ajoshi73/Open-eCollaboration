package se.sundsvall.collaborationroom.modules.task;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;


public class MyTasksBackgroundModule extends AnnotatedBackgroundModule {

	@InstanceManagerDependency(required = true)
	private MyTasksModule tasksModule;
	
	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();
		
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "moduleName", moduleDescriptor.getName());
		XMLUtils.appendNewElement(doc, documentElement, "tasksModuleAlias", req.getContextPath() + tasksModule.getFullAlias());
		documentElement.appendChild(user.toXML(doc));
		
		Element tasksElement = doc.createElement("ListTasks");

		doc.getFirstChild().appendChild(tasksElement);

		tasksModule.appendAdditionalTasks(doc, tasksElement, 0, user, req);
		
		return new SimpleBackgroundModuleResponse(doc);		
	}
	
}
