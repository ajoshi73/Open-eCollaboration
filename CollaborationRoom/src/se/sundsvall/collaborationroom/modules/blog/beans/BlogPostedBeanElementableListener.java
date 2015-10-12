package se.sundsvall.collaborationroom.modules.blog.beans;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.PostedBean;
import se.dosf.communitybase.interfaces.Posted;
import se.dosf.communitybase.interfaces.Role;
import se.sundsvall.collaborationroom.modules.blog.BlogModule;
import se.sundsvall.collaborationroom.modules.utils.PostedBeanElementableListener;
import se.unlogic.hierarchy.core.beans.User;


public class BlogPostedBeanElementableListener extends PostedBeanElementableListener<PostedBean> {

	private BlogModule blogModule;
	
	public BlogPostedBeanElementableListener(String languageCode, User user, Role role, BlogModule blogModule) {

		super(languageCode, user, role);
		
		this.blogModule = blogModule;
	}

	@Override
	protected void appendBeanAccess(Document doc, Element targetElement, User user, Posted bean, Role role) {

		blogModule.appendBeanAccess(doc, targetElement, user, bean, role);
	}
	
}
