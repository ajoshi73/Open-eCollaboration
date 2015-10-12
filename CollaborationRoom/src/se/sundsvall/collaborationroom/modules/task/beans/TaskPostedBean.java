package se.sundsvall.collaborationroom.modules.task.beans;

import java.sql.Timestamp;

import se.dosf.communitybase.interfaces.Posted;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.standardutils.dao.annotations.DAOManaged;
import se.unlogic.standardutils.xml.GeneratedElementable;
import se.unlogic.standardutils.xml.XMLElement;

public class TaskPostedBean extends GeneratedElementable implements Posted {

	@DAOManaged
	@XMLElement
	protected Timestamp posted;

	@DAOManaged(dontUpdateIfNull = true)
	@XMLElement(name="poster")
	protected User poster;

	@DAOManaged
	@XMLElement
	protected Timestamp updated;

	@DAOManaged(dontUpdateIfNull = true)
	@XMLElement(name="editor")
	protected User editor;

	@Override
	public Timestamp getPosted() {

		return posted;
	}

	@Override
	public void setPosted(Timestamp posted) {

		this.posted = posted;
	}

	@Override
	public User getPoster() {

		return poster;
	}

	@Override
	public void setPoster(User poster) {

		this.poster = poster;
	}

	@Override
	public Timestamp getUpdated() {

		return updated;
	}

	@Override
	public void setUpdated(Timestamp updated) {

		this.updated = updated;
	}

	@Override
	public User getEditor() {

		return editor;
	}

	@Override
	public void setEditor(User editor) {

		this.editor = editor;
	}
	
}
