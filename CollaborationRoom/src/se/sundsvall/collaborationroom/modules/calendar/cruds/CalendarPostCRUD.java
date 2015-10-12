package se.sundsvall.collaborationroom.modules.calendar.cruds;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.cruds.CBBaseCRUD;
import se.dosf.communitybase.interfaces.Role;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.calendar.BaseCalendarModule;
import se.sundsvall.collaborationroom.modules.calendar.beans.CalendarPost;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.utils.crud.IntegerBeanIDParser;
import se.unlogic.standardutils.dao.CRUDDAO;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.populators.UnixTimeDatePopulator;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.validation.ValidationErrorType;
import se.unlogic.standardutils.validation.ValidationException;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.populators.annotated.AnnotatedRequestPopulator;
import se.unlogic.webutils.validation.ValidationUtils;

public class CalendarPostCRUD extends CBBaseCRUD<CalendarPost, Integer, BaseCalendarModule> {

	private static final UnixTimeDatePopulator DATE_POPULATOR = new UnixTimeDatePopulator();

	private static final AnnotatedRequestPopulator<CalendarPost> POPULATOR = new AnnotatedRequestPopulator<CalendarPost>(CalendarPost.class);

	public CalendarPostCRUD(CRUDDAO<CalendarPost, Integer> crudDAO, BaseCalendarModule callback) {

		super(IntegerBeanIDParser.getInstance(), crudDAO, POPULATOR, "CalendarPost", "calendar post", "", callback);

	}

	@Override
	protected CalendarPost populateFromAddRequest(HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		CalendarPost calendarPost = super.populateFromAddRequest(req, user, uriParser);

		calendarPost.setSectionID(callback.getSectionID());

		calendarPost = populateFromRequest(calendarPost, req, user, uriParser);

		calendarPost.setPosted(TimeUtils.getCurrentTimestamp());
		calendarPost.setPoster(user);

		return calendarPost;
	}

	@Override
	protected CalendarPost populateFromUpdateRequest(CalendarPost bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		CalendarPost calendarPost = super.populateFromUpdateRequest(bean, req, user, uriParser);

		calendarPost = populateFromRequest(calendarPost, req, user, uriParser);

		calendarPost.setUpdated(TimeUtils.getCurrentTimestamp());
		calendarPost.setEditor(user);

		return calendarPost;
	}

	protected CalendarPost populateFromRequest(CalendarPost bean, HttpServletRequest req, User user, URIParser uriParser) throws ValidationException, Exception {

		List<ValidationError> errors = new ArrayList<ValidationError>();

		Date startDate = ValidationUtils.validateParameter("startDate", req, true, DATE_POPULATOR, errors);

		Date endDate = ValidationUtils.validateParameter("endDate", req, true, DATE_POPULATOR, errors);

		bean.setWholeDay(req.getParameter("wholeDay").equals("1"));

		Timestamp startTime = null;

		Timestamp endTime = null;

		if (startDate != null && endDate != null) {

			if (!bean.isWholeDay()) {

				startTime = this.getTime("startTime", req, startDate, errors);

				endTime = this.getTime("endTime", req, endDate, errors);

				if (startTime != null && endTime != null) {

					if (startDate.equals(endDate) && (endTime.equals(startTime) || endTime.before(startTime))) {
						errors.add(new ValidationError("EndTimeBeforeStartTime"));
					}

					if (DateUtils.daysBetween(startTime, endTime) < 0) {
						errors.add(new ValidationError("DaysBetweenToSmall"));
					}

				}

			} else {

				startTime = new Timestamp(startDate.getTime());

				endTime = new Timestamp(endDate.getTime());

				if (DateUtils.daysBetween(startTime, endTime) < 0) {
					errors.add(new ValidationError("DaysBetweenToSmall"));
				}

			}

		}

		if (!errors.isEmpty()) {
			throw new ValidationException(errors);
		}

		bean.setStartTime(startTime);
		bean.setEndTime(endTime);

		return bean;

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
	public ForegroundModuleResponse showUpdateForm(CalendarPost bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, ValidationException validationException) throws Exception {

		if (!req.getMethod().equalsIgnoreCase("POST")) {

			callback.redirectToMethod(req, res, "/showpost/" + bean.getPostID());

			return null;
		}

		if (uriParser.size() > 2) {

			return showBean(getBean(bean.getPostID(), SHOW, req), req, res, user, uriParser, validationException.getErrors());
		}

		return callback.defaultMethod(req, res, user, uriParser, validationException.getErrors());
	}

	protected Timestamp getTime(String fieldname, HttpServletRequest req, Date date, List<ValidationError> errors) {

		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);

		String time = req.getParameter(fieldname);

		if (!StringUtils.isEmpty(time)) {

			String[] timeParts = time.split(":");

			if (timeParts.length == 2 && NumberUtils.isInt(timeParts[0]) && NumberUtils.isInt(timeParts[1])) {

				calendar.set(Calendar.HOUR, Integer.parseInt(timeParts[0]));
				calendar.set(Calendar.MINUTE, Integer.parseInt(timeParts[1]));
				calendar.set(Calendar.MILLISECOND, 0);

				return new Timestamp(calendar.getTimeInMillis());

			}

			errors.add(new ValidationError(fieldname, ValidationErrorType.InvalidFormat));

		} else {

			errors.add(new ValidationError(fieldname, ValidationErrorType.RequiredField));
		}

		return null;

	}

	@Override
	protected ForegroundModuleResponse filteredBeanAdded(CalendarPost bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.redirectToMethod(req, res, "/show/" + bean.getPostID());

		return null;
	}

	@Override
	protected ForegroundModuleResponse filteredBeanUpdated(CalendarPost bean, HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		callback.redirectToMethod(req, res, "/show/" + bean.getPostID());

		return null;
	}

	@Override
	protected void appendShowFormData(CalendarPost bean, Document doc, Element showTypeElement, User user, HttpServletRequest req, HttpServletResponse res, URIParser uriParser) throws SQLException, IOException, Exception {

		XMLUtils.appendNewElement(doc, showTypeElement, "ShowProfileAlias", callback.getShowProfileAlias());

		if (req.getParameter("date") != null && DateUtils.isValidDate(DateUtils.DATE_FORMATTER, req.getParameter("date"))) {

			java.util.Date date = DateUtils.getDate(DateUtils.DATE_FORMATTER, req.getParameter("date"));

			XMLUtils.appendNewElement(doc, showTypeElement, "relatedDate", req.getParameter("date"));
			XMLUtils.appendNewElement(doc, showTypeElement, "formattedRelatedDate", callback.getFormattedDate(date, false));
			XMLUtils.append(doc, showTypeElement, "RelatedPosts", callback.getPosts(new Timestamp(date.getTime()), req, user));

		}

	}

	@Override
	protected void appendBean(CalendarPost calendarPost, Element targetElement, Document doc, User user) {

		Role role = callback.getCBInterface().getRole(callback.getSectionID(), user);

		Element postElement = calendarPost.toXML(doc);

		CBAccessUtils.appendBeanAccess(doc, postElement, user, calendarPost, role);

		XMLUtils.appendNewElement(doc, postElement, "formattedPostedDate", callback.getFormattedDateTime(calendarPost.getPosted(), true));

		if (calendarPost.getUpdated() != null) {
			XMLUtils.appendNewElement(doc, postElement, "formattedUpdatedDate", callback.getFormattedDateTime(calendarPost.getUpdated(), true));
		}

		XMLUtils.appendNewElement(doc, postElement, "formattedStartDate", callback.getFormattedDateTime(calendarPost.getStartTime(), !calendarPost.isWholeDay()));
		XMLUtils.appendNewElement(doc, postElement, "formattedEndDate", callback.getFormattedDateTime(calendarPost.getEndTime(), !calendarPost.isWholeDay()));

		targetElement.appendChild(postElement);
	}

	@Override
	protected void checkUpdateAccess(CalendarPost bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasUpdateContentAccess(user, bean, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Update " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

	@Override
	protected void checkDeleteAccess(CalendarPost bean, User user, HttpServletRequest req, URIParser uriParser) throws AccessDeniedException, URINotFoundException, SQLException {

		if (!CBAccessUtils.hasUpdateContentAccess(user, bean, callback.getCBInterface().getRole(callback.getSectionID(), user))) {

			throw new AccessDeniedException("Delete " + typeLogName + " " + bean + " denied in section " + callback.getSectionDescriptor());
		}
	}

}
