package se.sundsvall.collaborationroom.modules.link;

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

public class LinkArchiveBackgroundModule extends AnnotatedBackgroundModule {

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Entry<ForegroundModuleDescriptor, LinkArchiveModule> linkArchiveModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(LinkArchiveModule.class);

		if (linkArchiveModuleEntry != null) {

			LinkArchiveModule linkArchiveModule = linkArchiveModuleEntry.getValue();
		
			Document doc = XMLUtils.createDomDocument();
			Element documentElement = doc.createElement("Document");
			doc.appendChild(documentElement);
	
			XMLUtils.appendNewElement(doc, documentElement, "moduleName", moduleDescriptor.getName());
			XMLUtils.appendNewElement(doc, documentElement, "linkArchiveModuleAlias", linkArchiveModule.getFullAlias());
			XMLUtils.appendNewElement(doc, documentElement, "contextPath", req.getContextPath());
			
			
			Element listLinksElement = XMLUtils.appendNewElement(doc, documentElement, "ListLinks");
			
			linkArchiveModule.appendLinks(0, doc, listLinksElement, req);
			
			return new SimpleBackgroundModuleResponse(doc);
			
		}
		
		return null;
	}
	
}
