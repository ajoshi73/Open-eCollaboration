package se.sundsvall.collaborationroom.modules.filearchive.beans;

import java.sql.Timestamp;
import java.util.Locale;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.Role;
import se.sundsvall.collaborationroom.modules.utils.PostedBeanElementableListener;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.xml.XMLUtils;

public class FilePostedBeanElementableListener extends PostedBeanElementableListener<File> {

	public FilePostedBeanElementableListener(String languageCode, User user, Role role) {

		super(languageCode, user, role);
	}

	@Override
	public void elementGenerated(Document doc, Element element, File file) {

		super.elementGenerated(doc, element, file);

		Timestamp locked = file.getLocked();

		if (locked != null) {

			String formattedLockedDate = DateUtils.dateAndShortMonthToString(locked, new Locale(languageCode)) + " " + TimeUtils.TIME_FORMATTER.format(locked);

			XMLUtils.appendNewElement(doc, element, "formattedLockedDate", formattedLockedDate);
		}

	}

}
