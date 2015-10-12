package se.sundsvall.collaborationroom.modules.blog.beans;

import java.io.InputStream;
import java.util.List;

import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.string.StringUtils;


public class PostSearchableItem implements CBSearchableItem {

	private final Post post;
	private final String alias;

	public PostSearchableItem(Post post, String alias) {

		super();
		this.post = post;
		this.alias = alias;
	}

	@Override
	public String getTitle() {

		return post.getTitle();
	}

	@Override
	public String getAlias() {

		return alias;
	}

	@Override
	public String getID() {

		return post.getPostID().toString();
	}

	@Override
	public String getInfoLine() {

		return DateUtils.DATE_TIME_FORMATTER.format(post.getPosted());
	}

	@Override
	public String getContentType() {

		//TODO maybe change to text/plain
		return "text/html";
	}

	@Override
	public InputStream getData() throws Exception {

		return StringUtils.getInputStream(post.getMessage());
	}

	@Override
	public String getType() {

		return "post";
	}

	@Override
	public List<String> getTags() {

		return post.getTags();
	}
}
