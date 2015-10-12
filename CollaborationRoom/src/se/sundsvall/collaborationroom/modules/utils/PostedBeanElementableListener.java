package se.sundsvall.collaborationroom.modules.utils;

import java.sql.Timestamp;
import java.util.Locale;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.PostedBean;
import se.dosf.communitybase.interfaces.Posted;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.xml.ElementableListener;
import se.unlogic.standardutils.xml.XMLUtils;

public class PostedBeanElementableListener<T extends PostedBean> implements ElementableListener<T> {

	protected String languageCode;
	protected User user;
	protected Role role;

	public PostedBeanElementableListener(String languageCode, User user, Role role) {

		this.languageCode = languageCode;
		this.user = user;
		this.role = role;
	}

	@Override
	public void elementGenerated(Document doc, Element element, T postedBean) {

		String formattedPostedDate = DateUtils.dateAndShortMonthToString(postedBean.getPosted(), new Locale(languageCode)) + " " + TimeUtils.TIME_FORMATTER.format(postedBean.getPosted());
		
		XMLUtils.appendNewElement(doc, element, "formattedPostedDate", formattedPostedDate);
		
		Timestamp updated = postedBean.getUpdated();
		
		if(updated != null) {
			
			String formattedUpdatedDate = DateUtils.dateAndShortMonthToString(updated, new Locale(languageCode)) + " " + TimeUtils.TIME_FORMATTER.format(updated);
			
			XMLUtils.appendNewElement(doc, element, "formattedUpdatedDate", formattedUpdatedDate);
		}
		
		if(role != null) {
			appendBeanAccess(doc, element, user, postedBean, role);
		}
	}
	
	protected void appendBeanAccess(Document doc, Element targetElement, User user, Posted bean, Role role) {
		
		CBAccessUtils.appendBeanAccess(doc, targetElement, user, bean, role);
	}
}
