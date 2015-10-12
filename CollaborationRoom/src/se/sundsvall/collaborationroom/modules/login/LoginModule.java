package se.sundsvall.collaborationroom.modules.login;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;

import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.foregroundmodules.login.UserProviderLoginModule;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class LoginModule extends UserProviderLoginModule {

	@ModuleSetting(allowsNull = true)
	@TextFieldSettingDescriptor(name = "Internal user login url", description = "The full url to the internal login form", required = false)
	protected String internalUserLoginFormURL;

	@Override
	protected Document createDocument(HttpServletRequest req, URIParser uriParser) {

		Document doc = super.createDocument(req, uriParser);

		XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "internalUserLoginFormURL", internalUserLoginFormURL);

		return doc;
	}

}
