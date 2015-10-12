package se.sundsvall.collaborationroom.modules.blog.beans;

import java.lang.reflect.Field;

import se.dosf.communitybase.beans.PostedBean;
import se.unlogic.standardutils.annotations.WebPopulate;
import se.unlogic.standardutils.dao.annotations.DAOManaged;
import se.unlogic.standardutils.dao.annotations.Key;
import se.unlogic.standardutils.dao.annotations.ManyToOne;
import se.unlogic.standardutils.dao.annotations.Table;
import se.unlogic.standardutils.reflection.ReflectionUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.xml.XMLElement;

@Table(name = "communitybase_blog_post_comments")
@XMLElement
public class Comment extends PostedBean {

	public static final Field POST_RELATION = ReflectionUtils.getField(Comment.class, "post");

	@Key
	@DAOManaged(autoGenerated = true)
	@XMLElement
	private Integer commentID;

	@DAOManaged
	@WebPopulate(required = true, maxLength = 65536, paramName="comment")
	@XMLElement
	private String message;

	@DAOManaged(columnName="postID")
	@ManyToOne
	@XMLElement
	private Post post;

	public Integer getCommentID() {

		return commentID;
	}

	public void setCommentID(Integer commentID) {

		this.commentID = commentID;
	}

	public String getMessage() {

		return message;
	}

	public void setMessage(String message) {

		this.message = message;
	}

	public Post getPost() {

		return post;
	}

	public void setPost(Post post) {

		this.post = post;
	}

	@Override
	public int hashCode() {

		final int prime = 31;
		int result = 1;
		result = prime * result + ((commentID == null) ? 0 : commentID.hashCode());
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
		Comment other = (Comment) obj;
		if (commentID == null) {
			if (other.commentID != null) {
				return false;
			}
		} else if (!commentID.equals(other.commentID)) {
			return false;
		}
		return true;
	}

	@Override
	public String toString(){

		return StringUtils.toLogFormat(message, 30) + " (commentID: " + commentID + ")";
	}
}
