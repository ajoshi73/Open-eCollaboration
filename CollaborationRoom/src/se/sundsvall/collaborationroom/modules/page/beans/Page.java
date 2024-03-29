package se.sundsvall.collaborationroom.modules.page.beans;

import se.dosf.communitybase.beans.PostedBean;
import se.unlogic.standardutils.annotations.WebPopulate;
import se.unlogic.standardutils.dao.annotations.DAOManaged;
import se.unlogic.standardutils.dao.annotations.Key;
import se.unlogic.standardutils.dao.annotations.Table;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.xml.XMLElement;
import se.unlogic.webutils.annotations.URLRewrite;

@Table(name = "communitybase_page_pages")
@XMLElement
public class Page extends PostedBean implements Comparable<Page> {

	@Key
	@DAOManaged(autoGenerated = true)
	@XMLElement
	private Integer pageID;

	@DAOManaged
	@XMLElement
	private Integer sectionID;

	@DAOManaged
	@WebPopulate(maxLength = 255, required = true)
	@XMLElement
	private String title;

	@DAOManaged
	@WebPopulate(maxLength = 65536)
	@URLRewrite
	@XMLElement
	private String content;

	public Integer getPageID() {

		return pageID;
	}

	public void setPageID(Integer pageID) {

		this.pageID = pageID;
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

	public String getContent() {

		return content;
	}

	public void setContent(String content) {

		this.content = content;
	}

	@Override
	public int compareTo(Page other) {

		return title.toLowerCase().compareTo(other.getTitle().toLowerCase());
	}

	@Override
	public int hashCode() {

		final int prime = 31;
		int result = 1;
		result = prime * result + ((pageID == null) ? 0 : pageID.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {

		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		Page other = (Page) obj;
		if (pageID == null) {
			if (other.pageID != null) {
				return false;
			}
		} else if (!pageID.equals(other.pageID)) {
			return false;
		}
		return true;
	}

	@Override
	public String toString() {

		return StringUtils.toLogFormat(title, 30) + " (pageID: " + pageID + ")";
	}
}
