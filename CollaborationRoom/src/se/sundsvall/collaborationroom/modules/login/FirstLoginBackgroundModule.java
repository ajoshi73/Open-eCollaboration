package se.sundsvall.collaborationroom.modules.login;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.HTMLEditorSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.url.URLRewriter;

public class FirstLoginBackgroundModule extends AnnotatedBackgroundModule {

	private static final String IS_WELCOMED_ATTRIBUTE = "IsWelcomed";

	@ModuleSetting
	@HTMLEditorSettingDescriptor(name = "Welcome message", description = "The message shown after first login", required = true)
	private String welcomeMessage;

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		if (user.getLastLogin() == null && welcomeMessage != null) {

			HttpSession session = req.getSession();

			if (session.getAttribute(IS_WELCOMED_ATTRIBUTE) == null) {

				session.setAttribute(IS_WELCOMED_ATTRIBUTE, true);

				Document doc = XMLUtils.createDomDocument();

				Element document = doc.createElement("Document");
				doc.appendChild(document);

				XMLUtils.appendNewElement(doc, document, "welcomeMessage", URLRewriter.setAbsoluteLinkUrls(welcomeMessage, req));

				return new SimpleBackgroundModuleResponse(doc);

			}
		}

		return null;
	}

}
