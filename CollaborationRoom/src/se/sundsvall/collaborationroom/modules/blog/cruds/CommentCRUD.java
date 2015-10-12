package se.sundsvall.collaborationroom.modules.blog.cruds;

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.sundsvall.collaborationroom.modules.blog.BlogModule;
import se.sundsvall.collaborationroom.modules.blog.beans.Comment;
import se.sundsvall.collaborationroom.modules.blog.beans.Post;
import se.sundsvall.collaborationroom.modules.utils.RequestOrURIParserBeanIDParser;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;

public class CommentCRUD extends CBBaseCRUD<Comment, Integer, BlogModule> {

	private static final RequestOrURIParserBeanIDParser ID_PARSER = new RequestOrURIParserBeanIDParser("commentID");

	private static final AnnotatedRequestPopulator<Comment> POPULATOR = new AnnotatedRequestPopulator<Comment>(Comment.class);

	private AdvancedAnnotatedDAOWrapper<Comment, Integer> crudDAO;

	public CommentCRUD(AdvancedAnnotatedDAOWrapper<Comment, Integer> crudDAO, BlogModule callback) {

		super(ID_PARSER, crudDAO, POPULATOR, "Comment", "comment", "", callback);

		this.crudDAO = crudDAO;

	}

	@Override
	protected Comment populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Post post = callback.getPostCRUD().getRequestedBean(req, null, user, uriParser, UPDATE);

		if (post == null) {

			throw new URINotFoundException(uriParser);
		}

		req.setAttribute("post", post);

		Comment comment = super.populateFromAddRequest(req, user, uriParser);

		comment.setPost(post);

		return comment;
	}

	@Override
	public ForegroundModuleResponse showAddForm(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		Post post = (Post) req.getAttribute("post");

		if (post == null) {

			post = callback.getPostCRUD().getRequestedBean(req, null, user, uriParser, UPDATE);

			if (post == null) {

				throw new URINotFoundException(uriParser);
			}
		}

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "/show/" + post.getPostID());

			return null;
		}

		return callback.getPostCRUD().showBean(post, req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	public ForegroundModuleResponse showUpdateForm(Comment bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "/show/" + bean.getPost().getPostID());

			return null;
		}

		return callback.getPostCRUD().showBean(bean.getPost(), req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	public Comment getBean(Integer beanID, String getMode, HttpServletRequest req) throws SQLException, AccessDeniedException {

		if (getMode != null && (getMode == UPDATE || getMode == DELETE)) {

			HighLevelQuery<Comment> query = new HighLevelQuery<Comment>(Comment.POST_RELATION);

			query.addParameter(crudDAO.getParameterFactory().getParameter(beanID));

			return crudDAO.getAnnotatedDAO().get(query);
		}

		return super.getBean(beanID, getMode, req);
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(Comment bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cachePost(bean.getPost().getPostID());

		callback.redirectToMethod(req, res, "/show/" + bean.getPost().getPostID() + "#c" + bean.getCommentID());

		callback.commentAdded(bean);

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(Comment bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cachePost(bean.getPost().getPostID());

		callback.redirectToMethod(req, res, "/show/" + bean.getPost().getPostID() + "#c" + bean.getCommentID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(Comment bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.cachePost(bean.getPost().getPostID());

		callback.redirectToMethod(req, res, "/show/" + bean.getPost().getPostID());

		callback.commentDeleted(bean);

		return null;
	}
	
	@Override
	protected void checkAddAccess(User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {
		
		if(!callback.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))){
			
			throw new AccessDeniedException("Add " + typeLogName + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkUpdateAccess(Comment bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if(!callback.hasUpdateContentAccess(user, bean, callback.getCBInterface().getRole(callback.getSectionID(), user))){
			
			throw new AccessDeniedException("Update " + typeLogName + " " + bean +  " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(Comment bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if(!callback.hasDeleteContentAccess(user, bean, callback.getCBInterface().getRole(callback.getSectionID(), user))){
			
			throw new AccessDeniedException("Delete " + typeLogName + " " + bean +  " denied in section " + callback.getSectionDescriptor());
		}
	}
	
}
