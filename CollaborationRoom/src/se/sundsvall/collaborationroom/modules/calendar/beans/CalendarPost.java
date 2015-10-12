package se.sundsvall.collaborationroom.modules.calendar.beans;

import java.sql.Timestamp;
import java.util.Calendar;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.PostedBean;
import se.unlogic.standardutils.annotations.WebPopulate;
import se.unlogic.standardutils.dao.annotations.DAOManaged;
import se.unlogic.standardutils.dao.annotations.Key;
import se.unlogic.standardutils.dao.annotations.Table;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.json.JsonArray;
import se.unlogic.standardutils.json.JsonObject;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.xml.XMLElement;
import se.unlogic.standardutils.xml.XMLGenerator;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.annotations.URLRewrite;

@Table(name = "communitybase_calendar_posts")
@XMLElement
public class CalendarPost extends PostedBean {

	@Key
	@DAOManaged(autoGenerated = true)
	@XMLElement
	private Integer postID;

	@DAOManaged
	@XMLElement
	private Integer sectionID;

	@DAOManaged
	@WebPopulate(maxLength = 255, required = true)
	@XMLElement(cdata = true)
	private String title;

	@URLRewrite
	@DAOManaged
	@WebPopulate(maxLength = 65535)
	@XMLElement(cdata = true)
	private String description;

	@DAOManaged
	@WebPopulate(maxLength = 255)
	@XMLElement(cdata = true)
	private String location;

	@DAOManaged
	@XMLElement
	private boolean wholeDay;

	@DAOManaged
	private Timestamp startTime;

	@DAOManaged
	private Timestamp endTime;

	@XMLElement
	private String fullAlias;
	
	@XMLElement
	private String sectionName;

	public Integer getPostID() {

		return postID;
	}

	public void setPostID(Integer postID) {

		this.postID = postID;
	}

	public Integer getSectionID() {

		return sectionID;
	}

	public void setSectionID(Integer sectionID) {

		this.sectionID = sectionID;
	}

	public String getTitle() {

		return title;
	}

	public void setTitle(String title) {

		this.title = title;
	}

	public String getDescription() {

		return description;
	}

	public void setDescription(String description) {

		this.description = description;
	}

	public String getLocation() {

		return location;
	}

	public void setLocation(String location) {

		this.location = location;
	}

	public boolean isWholeDay() {

		return wholeDay;
	}

	public void setWholeDay(boolean wholeDay) {

		this.wholeDay = wholeDay;
	}

	public Timestamp getStartTime() {

		return startTime;
	}

	public void setStartTime(Timestamp startTime) {

		this.startTime = startTime;
	}

	public Timestamp getEndTime() {

		return endTime;
	}

	public void setEndTime(Timestamp endTime) {

		this.endTime = endTime;
	}

	public String getFullAlias() {

		return fullAlias;
	}

	public void setFullAlias(String fullAlias) {

		this.fullAlias = fullAlias;
	}

	
	public String getSectionName() {
	
		return sectionName;
	}

	
	public void setSectionName(String sectionName) {
	
		this.sectionName = sectionName;
	}

	@Override
	public Element toXML(Document doc) {

		Element calendarPostElement = XMLGenerator.toXML(this, doc);

		if (startTime != null && endTime != null) {

			XMLUtils.appendNewElement(doc, calendarPostElement, "startTime", TimeUtils.TIME_FORMATTER.format(startTime));
			XMLUtils.appendNewElement(doc, calendarPostElement, "endTime", TimeUtils.TIME_FORMATTER.format(endTime));

			XMLUtils.appendNewElement(doc, calendarPostElement, "startDate", DateUtils.DATE_FORMATTER.format(startTime));
			XMLUtils.appendNewElement(doc, calendarPostElement, "endDate", DateUtils.DATE_FORMATTER.format(endTime));

		}

		return calendarPostElement;
	}

	public void appendJSON(JsonArray jsonArray) {

		Calendar start = Calendar.getInstance();
		start.setTime(startTime);
		start.set(Calendar.HOUR_OF_DAY, 0);
		start.set(Calendar.MINUTE, 0);

		Calendar end = Calendar.getInstance();
		end.setTime(endTime);
		end.set(Calendar.HOUR_OF_DAY, 0);
		end.set(Calendar.MINUTE, 0);

		while (!start.after(end)) {

			String date = DateUtils.DATE_FORMATTER.format(start.getTime());

			JsonObject postJSON = new JsonObject();
			postJSON.putField("postID", postID);
			postJSON.putField("title", title);
			postJSON.putField("location", location != null ? location : "-");
			postJSON.putField("date", date);
			postJSON.putField("startTime", this.startTime.getTime());
			postJSON.putField("endTime", this.endTime.getTime());
			postJSON.putField("allDay", wholeDay);

			postJSON.putField("posted", posted);
			if (poster != null) {
				postJSON.putField("postedBy", poster.getFirstname() + " " + poster.getLastname());
			}

			if (fullAlias != null) {
				postJSON.putField("postURI", fullAlias + "?date=" + date);
			}
			
			if(sectionName != null) {
				postJSON.putField("postedIn", sectionName);
			}

			jsonArray.addNode(postJSON);

			start.add(Calendar.DATE, 1);
		}

	}

	@Override
	public String toString() {

		return StringUtils.toLogFormat(title, 30) + " (ID: " + postID + ")";
	}

	@Override
	public int hashCode() {

		final int prime = 31;
		int result = 1;
		result = prime * result + ((postID == null) ? 0 : postID.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {

		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		CalendarPost other = (CalendarPost) obj;
		if (postID == null) {
			if (other.postID != null)
				return false;
		} else if (!postID.equals(other.postID))
			return false;
		return true;
	}

}
