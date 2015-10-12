package se.sundsvall.collaborationroom.modules.preferedsections.beans;

import se.unlogic.standardutils.dao.annotations.DAOManaged;
import se.unlogic.standardutils.dao.annotations.Key;
import se.unlogic.standardutils.dao.annotations.Table;
import se.unlogic.standardutils.xml.GeneratedElementable;
import se.unlogic.standardutils.xml.XMLElement;

@Table(name = "communitybase_prefered_sections")
@XMLElement
public class PreferedSection extends GeneratedElementable {

	@Key
	@DAOManaged
	@XMLElement
	private Integer userID;

	@Key
	@DAOManaged
	@XMLElement
	private Integer sectionID;

	public PreferedSection() { }
	
	public PreferedSection(Integer userID, Integer sectionID) {

		this.userID = userID;
		this.sectionID = sectionID;
	}

	public Integer getUserID() {

		return userID;
	}

	public void setUserID(Integer userID) {

		this.userID = userID;
	}

	public Integer getSectionID() {

		return sectionID;
	}

	public void setSectionID(Integer sectionID) {

		this.sectionID = sectionID;
	}

}