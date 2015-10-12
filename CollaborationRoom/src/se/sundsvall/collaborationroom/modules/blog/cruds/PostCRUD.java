package se.sundsvall.collaborationroom.modules.blog.cruds;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.dosf.communitybase.interfaces.Role;
import se.sundsvall.collaborationroom.modules.blog.BlogModule;
import se.sundsvall.collaborationroom.modules.blog.beans.BlogPostedBeanElementableListener;
import se.sundsvall.collaborationroom.modules.blog.beans.Comment;
import se.sundsvall.collaborationroom.modules.blog.beans.Post;
import se.sundsvall.collaborationroom.modules.filearchive.FileArchiveModule;
import se.sundsvall.collaborationroom.modules.filearchive.beans.File;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.crud.IntegerBeanIDParser;
import se.unlogic.standardutils.dao.CRUDDAO;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.populators.IntegerPopulator;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.standardutils.xml.XMLGeneratorDocument;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;
import se.unlogic.webutils.validation.ValidationUtils;

public class PostCRUD extends CBBaseCRUD<Post, Integer, BlogModule> {

	private static final AnnotatedRequestPopulator<Post> POPULATOR = new AnnotatedRequestPopulator<Post>(Post.class);

	public PostCRUD(CRUDDAO<Post, Integer> crudDAO, BlogModule callback) {

		super(IntegerBeanIDParser.getInstance(), crudDAO, POPULATOR, "Post", "post", "", callback);
	}

	@Override
	protected void validateAddPopulation(Post bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, SQLException, Exception {

		bean.setSectionID(callback.getSectionID());
	}

	@Override
	protected void appendBean(Post post, Element targetElement, Document doc, User user) {

		XMLGeneratorDocument generatorDocument = new XMLGeneratorDocument(doc);

		Role role = callback.getCBInterface().getRole(callback.getSectionID(), user);

		BlogPostedBeanElementableListener elementableListener = new BlogPostedBeanElementableListener(callback.getLanguageCode(), user, role, callback);

		generatorDocument.addElementableListener(Comment.class, elementableListener);
		generatorDocument.addElementableListener(Post.class, elementableListener);

		Element postElement = post.toXML(generatorDocument);

		callback.appendAttachedFiles(post, generatorDocument, postElement);
		callback.appendBeanAccess(generatorDocument, postElement, user, post, role);

		XMLUtils.appendNewElement(generatorDocument, postElement, "formattedPostedDate", callback.getFormattedDate(post.getPosted()));

		if (post.getUpdated() != null) {

			XMLUtils.appendNewElement(generatorDocument, postElement, "formattedUpdatedDate", callback.getFormattedDate(post.getUpdated()));
		}

		targetElement.appendChild(postElement);
	}

	@Override
	protected void appendShowFormData(Post bean, Document doc, Element showTypeElement, User user, HttpServletRequest req, HttpServletResponse res, URIParser uriParser) throws SQLException, IOException, Exception {

		FileArchiveModule fileArchiveModule = callback.getFileArchiveModule();

		if (fileArchiveModule != null) {

			if (req.getParameterValues("fileID") != null) {

				showTypeElement.appendChild(RequestUtils.getRequestParameters(req, doc));

				List<Integer> fileIDs = NumberUtils.toInt(req.getParameterValues("fileID"));

				if (fileIDs != null) {

					XMLUtils.append(doc, showTypeElement, "AttachedFiles", fileArchiveModule.getFiles(fileIDs));

				}

			}

		}
		
	}

	@Override
	public ForegroundModuleResponse showAddForm(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToDefaultMethod(req, res, "add");

			return null;
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());

	}

	@Override
	public ForegroundModuleResponse showUpdateForm(Post bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "/show/" + bean.getPostID() + "#update");

			return null;
		}

		return showBean(bean, req, res, user, uriParser, validationException.getErrors());
	}

	@Override
	protected Post populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Post post = super.populateFromAddRequest(req, user, uriParser);

		post.setLinkedFiles(populateFiles(req));
		post.setTags(populateTags(req, user, uriParser));
		post.setPoster(user);
		post.setPosted(TimeUtils.getCurrentTimestamp());
		post.setFollowers(Collections.singletonList(user.getUserID()));

		return post;
	}

	@Override
	protected Post populateFromUpdateRequest(Post bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		Post post = super.populateFromUpdateRequest(bean, req, user, uriParser);

		post.setLinkedFiles(populateFiles(req));
		post.setTags(populateTags(req, user, uriParser));
		post.setEditor(user);
		post.setUpdated(TimeUtils.getCurrentTimestamp());

		return post;
	}

	protected List<String> populateTags(HttpServletRequest req, User user, URIParser uriParser) {

		String tags = req.getParameter("tags");

		List<String> populatedTags = null;

		if (tags != null) {

			populatedTags = new ArrayList<String>();

			for (String tag : tags.split(",")) {

				String populatedTag = tag.trim();

				if (!StringUtils.isEmpty(populatedTag)) {
					populatedTags.add(populatedTag);
				}
			}

		}

		return populatedTags;
	}

	protected List<Integer> populateFiles(HttpServletRequest req) throws SQLException, ValidationException {

		FileArchiveModule fileArchiveModule = callback.getFileArchiveModule();

		if (fileArchiveModule != null) {

			List<ValidationError> errors = new ArrayList<ValidationError>();

			List<Integer> fileIDs = ValidationUtils.validateParameters("fileID", req, false, IntegerPopulator.getPopulator(), errors);

			if (fileIDs != null) {

				List<File> files = fileArchiveModule.getFiles(fileIDs);

				if (files != null && fileIDs.size() != files.size()) {

					throw new ValidationException(new ValidationError("AttachedFileMissing"));

				}

				return fileIDs;
			}

		}

		return null;
	}

	@Override
	public Post getBean(Integer beanID, String getMode, HttpServletRequest req) throws SQLException, AccessDeniedException {

		if (getMode != null && getMode == SHOW) {

			return callback.getCachedPost(beanID);
		}

		return super.getBean(beanID, getMode, req);
	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(Post bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.postAdded(bean);

		return super.filteredBeanAdded(bean, req, res, user, uriParser);
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(Post bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.postUpdated(bean);

		callback.redirectToMethod(req, res, "/show/" + bean.getPostID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanDeleted(Post bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.postDeleted(bean);

		return super.filteredBeanDeleted(bean, req, res, user, uriParser);
	}

	@Override
	protected void checkAddAccess(User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!callback.hasAddContentAccess(user, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Add " + typeLogName + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkUpdateAccess(Post bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!callback.hasUpdateContentAccess(user, bean, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Update " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(Post bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!callback.hasDeleteContentAccess(user, bean, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Delete " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}
}
