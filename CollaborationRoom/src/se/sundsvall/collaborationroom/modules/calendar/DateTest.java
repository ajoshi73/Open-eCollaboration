package se.sundsvall.collaborationroom.modules.calendar;

import java.text.SimpleDateFormat;
import java.util.Date;

import se.unlogic.standardutils.string.StringUtils;


public class DateTest {

	public static void main(String[] args) {

		SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE dd MMMM yyyy HH:mm");

		System.out.println(StringUtils.toSentenceCase(dateFormat.format(new Date())));

	}

}
