package se.sundsvall.collaborationroom.modules.blog;

import javax.servlet.http.HttpServletRequest;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.webutils.http.URIParser;

public class LatestUserPostsBackgroundModule extends AnnotatedBackgroundModule {

	@InstanceManagerDependency(required = true)
	private LatestUserPostsModule latestUserPostsModule;
	
	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = latestUserPostsModule.createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("LatestPosts");
		doc.getFirstChild().appendChild(listPostsElement);

		latestUserPostsModule.appendPosts(0, doc, listPostsElement, user);

		return new SimpleBackgroundModuleResponse(doc);
	}
	
}
