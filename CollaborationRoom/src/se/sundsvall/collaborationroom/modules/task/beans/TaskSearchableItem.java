package se.sundsvall.collaborationroom.modules.task.beans;

import java.io.InputStream;
import java.util.List;

import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.unlogic.standardutils.string.StringUtils;


public class TaskSearchableItem implements CBSearchableItem {

	private final Task task;
	private final String content;
	private final String alias;

	public TaskSearchableItem(Task task, String content, String alias) {

		super();
		this.task = task;
		this.content = content;
		this.alias = alias;
	}

	@Override
	public String getID() {

		return task.getTaskID().toString();
	}

	@Override
	public String getAlias() {

		return alias;
	}

	@Override
	public String getTitle() {

		return StringUtils.substring(task.getTitle(), 50, "...");
	}

	@Override
	public String getInfoLine() {

		return null;
	}

	@Override
	public String getContentType() {

		return "text/plain";
	}

	@Override
	public InputStream getData() throws Exception {

		return StringUtils.getInputStream(content);
	}

	@Override
	public String getType() {

		return "task";
	}

	@Override
	public List<String> getTags() {

		return null;
	}
}
