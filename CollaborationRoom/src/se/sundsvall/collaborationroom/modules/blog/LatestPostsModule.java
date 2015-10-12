package se.sundsvall.collaborationroom.modules.blog;

import java.lang.ref.WeakReference;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.modules.CBBaseModule;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.ModuleUtils;
import se.unlogic.standardutils.collections.MapUtils;
import se.unlogic.standardutils.references.WeakReferenceUtils;
import se.unlogic.webutils.http.URIParser;

public class LatestPostsModule extends CBBaseModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Post load count", description = "The number of posts to load on the firstpage and each time more posts are requested")
	private Integer postLoadCount = 3;

	private WeakReference<BlogModule> blogModuleReference;

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		BlogModule blogModule = getBlogModule();

		if (blogModule != null) {

			Document doc = blogModule.createDocument(req, uriParser, user);
			Element listPostsElement = doc.createElement("LatestPosts");
			doc.getFirstChild().appendChild(listPostsElement);

			Role role = cbInterface.getRole(getSectionID(), user);

			blogModule.appendBlogPosts(0, postLoadCount, doc, listPostsElement, user, role);

			return new SimpleForegroundModuleResponse(doc, this.getDefaultBreadcrumb());
		}

		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("LatestPosts");
		doc.getFirstChild().appendChild(listPostsElement);

		return new SimpleForegroundModuleResponse(doc, this.getDefaultBreadcrumb());
	}

	@WebPublic(alias = "getposts")
	public ForegroundModuleResponse getMorePosts(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		BlogModule blogModule = getBlogModule();

		if (blogModule != null) {

			return blogModule.loadAdditionalPosts(req, res, user, uriParser);

		}

		return null;
	}

	protected BlogModule getBlogModule() {

		BlogModule blogModule = WeakReferenceUtils.getReferenceValue(this.blogModuleReference);

		if (blogModule != null) {

			return blogModule;
		}

		blogModule = MapUtils.getEntryValue(ModuleUtils.findForegroundModule(BlogModule.class, true, null, false, sectionInterface));

		if (blogModule != null) {

			this.blogModuleReference = new WeakReference<BlogModule>(blogModule);

		} else {

			this.blogModuleReference = null;
		}

		return blogModule;

	}

}
