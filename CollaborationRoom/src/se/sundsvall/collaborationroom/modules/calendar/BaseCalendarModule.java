package se.sundsvall.collaborationroom.modules.calendar;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DateFormatSymbols;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.modules.CBBaseModule;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.calendar.beans.CalendarPost;
import se.sundsvall.collaborationroom.modules.calendar.cruds.CalendarPostCRUD;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.WebPublic;
import se.unlogic.hierarchy.core.beans.SimpleForegroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionDescriptor;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.core.utils.crud.TransactionRequestFilter;
import se.unlogic.standardutils.dao.AdvancedAnnotatedDAOWrapper;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.db.tableversionhandler.TableVersionHandler;
import se.unlogic.standardutils.db.tableversionhandler.UpgradeResult;
import se.unlogic.standardutils.db.tableversionhandler.XMLDBScriptProvider;
import se.unlogic.standardutils.json.JsonArray;
import se.unlogic.standardutils.json.JsonObject;
import se.unlogic.standardutils.json.JsonUtils;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.MillisecondTimeUnits;
import se.unlogic.standardutils.time.TimeUtils;
import se.unlogic.standardutils.validation.ValidationError;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.HTTPUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;

public abstract class BaseCalendarModule extends CBBaseModule {
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Calendar days load count", description = "The number of days to load on the firstpage in the agenda calendar", required = true)
	protected Integer daysLoadCount = 3;

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Max day search count", description = "The maximum number of days to search for coming calendar posts", required = true)
	protected Integer maxDaySearchCount = 90;

	@InstanceManagerDependency(required = false)
	private UserProfileProvider userProfileProvider;

	@InstanceManagerDependency(required = false)
	protected ICalModule iCalModule;
	
	protected AdvancedAnnotatedDAOWrapper<CalendarPost, Integer> postDAO;

	protected CalendarPostCRUD postCRUD;

	protected QueryParameterFactory<CalendarPost, Timestamp> startDateParamFactory;
	protected QueryParameterFactory<CalendarPost, Timestamp> endDateParamFactory;

	private String[] dayNames;
	private String[] monthNames;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		DateFormatSymbols dateFormatSymbols = new DateFormatSymbols(new Locale(systemInterface.getDefaultLanguage().getLanguageCode()));

		dayNames = dateFormatSymbols.getWeekdays();
		monthNames = dateFormatSymbols.getShortMonths();
	}

	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		UpgradeResult upgradeResult = TableVersionHandler.upgradeDBTables(dataSource, CalendarModule.class.getName(), new XMLDBScriptProvider(this.getClass().getResourceAsStream("dbscripts/DB script.xml")));

		if (upgradeResult.isUpgrade()) {

			log.info(upgradeResult.toString());
		}

		HierarchyAnnotatedDAOFactory daoFactory = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface);

		postDAO = daoFactory.getDAO(CalendarPost.class).getAdvancedWrapper(Integer.class);

		startDateParamFactory = postDAO.getAnnotatedDAO().getParamFactory("startTime", Timestamp.class);
		endDateParamFactory = postDAO.getAnnotatedDAO().getParamFactory("endTime", Timestamp.class);

		postCRUD = new CalendarPostCRUD(postDAO, this);
		postCRUD.addRequestFilter(new TransactionRequestFilter(dataSource));
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		return defaultMethod(req, res, user, uriParser, null);

	}

	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		HttpSession session = req.getSession();

		String mode = req.getParameter("view") != null ? req.getParameter("view") : (String) session.getAttribute("calendarView_" + getSectionID());

		if (mode != null && mode.equals("agenda")) {

			session.setAttribute("calendarView_" + getSectionID(), "agenda");

			return showAgenda(req, res, user, uriParser, validationErrors);
		}

		session.setAttribute("calendarView_" + getSectionID(), "month");

		return showMonth(req, res, user, uriParser, validationErrors);
	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse getPosts(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		if (req.getParameter("month") == null) {

			throw new URINotFoundException(uriParser);

		} else {

			String[] monthParts = req.getParameter("month").split("-");

			if (monthParts.length != 2 || !NumberUtils.isInt(monthParts[0]) || !NumberUtils.isInt(monthParts[1])) {

				throw new URINotFoundException(uriParser);
			}

			Calendar calendar = Calendar.getInstance();

			calendar.set(Integer.valueOf(monthParts[0]), Integer.valueOf(monthParts[1]) - 2, 1, 0, 0);

			Timestamp startDate = new Timestamp(calendar.getTimeInMillis());

			calendar.set(Calendar.MONTH, calendar.get(Calendar.MONTH) + 2);

			calendar.set(Calendar.DATE, calendar.getActualMaximum(Calendar.DATE));

			Timestamp endDate = new Timestamp(calendar.getTimeInMillis());

			HTTPUtils.sendReponse(getPostsJSON(startDate, endDate, req, user).toJson(), JsonUtils.getContentType(), res);

			return null;

		}

	}

	@WebPublic
	public ForegroundModuleResponse show(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkCRUDSupport(req, res, user, uriParser);

		return postCRUD.show(req, res, user, uriParser);
	}

	@WebPublic
	public ForegroundModuleResponse add(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkCRUDSupport(req, res, user, uriParser);

		return postCRUD.add(req, res, user, uriParser);
	}

	@WebPublic
	public ForegroundModuleResponse update(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkCRUDSupport(req, res, user, uriParser);

		return postCRUD.update(req, res, user, uriParser);
	}

	@WebPublic
	public ForegroundModuleResponse delete(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		checkCRUDSupport(req, res, user, uriParser);

		return postCRUD.delete(req, res, user, uriParser);
	}

	public ForegroundModuleResponse showMonth(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		log.info("User " + user + " requested calendar month view in section " + sectionInterface.getSectionDescriptor());
		
		Document doc = createDocument(req, uriParser, user);

		Element monthElement = doc.createElement("ShowMonthCalendar");

		doc.getFirstChild().appendChild(monthElement);

		appendCurrentTimeInformation(doc, monthElement);

		appendCurrentMonthPosts(doc, monthElement, req, user);

		appendUserSections(doc, monthElement, req, user);

		if(iCalModule != null){
			
			XMLUtils.appendNewElement(doc, monthElement, "ICalAvailable");
		}
		
		if (validationErrors != null) {
			XMLUtils.append(doc, monthElement, validationErrors);
			monthElement.appendChild(RequestUtils.getRequestParameters(req, doc));
		}

		return new SimpleForegroundModuleResponse(doc, this.getDefaultBreadcrumb());

	}

	public ForegroundModuleResponse showAgenda(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, List<ValidationError> validationErrors) throws Exception {

		log.info("User " + user + " requested calendar agenda view in section " + sectionInterface.getSectionDescriptor());
		
		Document doc = createDocument(req, uriParser, user);

		Element agendaElement = doc.createElement("ShowAgendaCalendar");

		doc.getFirstChild().appendChild(agendaElement);

		appendCurrentTimeInformation(doc, agendaElement);

		appendDays(TimeUtils.getCurrentTimestamp(), daysLoadCount, doc, agendaElement, req, user);

		appendUserSections(doc, agendaElement, req, user);

		if (validationErrors != null) {
			XMLUtils.append(doc, agendaElement, validationErrors);
			agendaElement.appendChild(RequestUtils.getRequestParameters(req, doc));
		}

		return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());

	}

	@WebPublic(toLowerCase = true)
	public ForegroundModuleResponse loadMoreDays(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Date lastDate = null;

		if (req.getParameter("lastdate") == null || (lastDate = DateUtils.getDate(DateUtils.DATE_FORMATTER, req.getParameter("lastdate"))) == null) {

			throw new URINotFoundException(uriParser);
		}

		Document doc = createDocument(req, uriParser, user);

		Element loadElement = doc.createElement("LoadMoreDays");

		doc.getFirstChild().appendChild(loadElement);

		Timestamp nextDate = new Timestamp(lastDate.getTime() + MillisecondTimeUnits.DAY);

		appendDays(nextDate, daysLoadCount, doc, loadElement, req, user);

		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		return moduleResponse;
	}

	@WebPublic(alias="ical")
	public ForegroundModuleResponse showiCalInformation(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {
		
		if(iCalModule == null){
			
			throw new URINotFoundException(uriParser);
		}
		
		Document doc = createDocument(req, uriParser, user);
		Element icalInformationElement = doc.createElement("ICalInfo");
		doc.getFirstChild().appendChild(icalInformationElement);
		
		String iCalURL = getiCalURL(user);
		
		if(iCalURL != null){
		
			XMLUtils.appendNewCDATAElement(doc, icalInformationElement, "Message", iCalModule.getIcalAvailableMessage());
			
		}else{
			
			XMLUtils.appendNewCDATAElement(doc, icalInformationElement, "Message", iCalModule.getIcalNotAvailableMessage());
		}
		
		XMLUtils.appendNewElement(doc, icalInformationElement, "ICalURL", iCalURL);
		
		return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());
	}
	
	protected abstract String getiCalURL(User user);

	protected List<SectionDescriptor> getSectionDescriptors() {

		return Arrays.asList(sectionInterface.getSectionDescriptor());
	}

	protected void appendDays(Date startDate, int loadCount, Document doc, Element targetElement, HttpServletRequest req, User user) throws SQLException {

		Calendar calendar = Calendar.getInstance();
		calendar.setTime(startDate);
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);

		int loadedDays = 0;
		int searchCount = 0;

		while (searchCount <= maxDaySearchCount) {

			if (loadedDays == loadCount) {
				break;
			}

			List<CalendarPost> posts = getPosts(new Timestamp(calendar.getTimeInMillis()), req, user);

			if (posts != null) {

				Element dayElement = doc.createElement("Day");

				XMLUtils.appendNewElement(doc, dayElement, "date", DateUtils.DATE_FORMATTER.format(calendar.getTime()));

				String weekDay = dayNames[calendar.get(Calendar.DAY_OF_WEEK)];

				XMLUtils.appendNewElement(doc, dayElement, "formattedDate", weekDay.substring(0, 1).toUpperCase() + weekDay.substring(1) + " " + calendar.get(Calendar.DATE) + " " + monthNames[calendar.get(Calendar.MONTH)] + " " + calendar.get(Calendar.YEAR));
				XMLUtils.append(doc, dayElement, posts);

				targetElement.appendChild(dayElement);

				loadedDays++;
			}

			searchCount++;

			calendar.add(Calendar.DATE, 1);
		}

	}

	public void appendCurrentMonthPosts(Document doc, Element element, HttpServletRequest req, User user) throws SQLException {

		Calendar calendar = Calendar.getInstance();

		calendar.set(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH) - 2, 1, 0, 0);

		Timestamp startDate = new Timestamp(calendar.getTimeInMillis());

		calendar.set(Calendar.MONTH, calendar.get(Calendar.MONTH) + 3);

		calendar.set(Calendar.DATE, calendar.getActualMaximum(Calendar.DATE));

		Timestamp endDate = new Timestamp(calendar.getTimeInMillis());

		XMLUtils.appendNewCDATAElement(doc, element, "initialPosts", getPostsJSON(startDate, endDate, req, user).toJson());

	}

	protected void appendCurrentTimeInformation(Document doc, Element element) {

		Timestamp currentTime = TimeUtils.getCurrentTimestamp();

		XMLUtils.appendNewElement(doc, element, "currentDate", DateUtils.DATE_FORMATTER.format(currentTime));
		XMLUtils.appendNewElement(doc, element, "currentTime", TimeUtils.TIME_FORMATTER.format(currentTime));
		XMLUtils.appendNewElement(doc, element, "nextHourTime", TimeUtils.TIME_FORMATTER.format(currentTime.getTime() + MillisecondTimeUnits.HOUR));

	}

	@Override
	protected String getMethod(HttpServletRequest req, URIParser uriParser) {

		String uriMethod = null;

		if (uriParser.size() > 1) {

			uriMethod = uriParser.get(1);
		}

		String paramMethod = req.getParameter("method");

		if (!StringUtils.isEmpty(paramMethod)) {

			if (!StringUtils.isEmpty(uriMethod)) {

				req.setAttribute("redirectURI", uriParser.getFormattedURI());

			}

			return paramMethod;

		}

		return uriMethod;
	}

	private JsonObject getPostsJSON(Timestamp startDate, Timestamp endDate, HttpServletRequest req, User user) throws SQLException {

		List<CalendarPost> posts = getPosts(startDate, endDate, req, user);

		JsonObject postsJSON = new JsonObject();

		JsonArray jsonArray = new JsonArray();

		if (posts != null) {

			for (CalendarPost post : posts) {

				post.appendJSON(jsonArray);

			}

		}

		postsJSON.putField("posts", jsonArray);

		return postsJSON;
	}

	public String getLanguageCode() {

		return systemInterface.getDefaultLanguage().getLanguageCode();
	}

	public String getFormattedDateTime(Timestamp date, boolean addTime) {

		return getFormattedDate(date, addTime);

	}

	public String getFormattedDate(Date date, boolean addTime) {

		return DateUtils.dateAndShortMonthToString(date, new Locale(systemInterface.getDefaultLanguage().getLanguageCode())) + (addTime ? " " + TimeUtils.TIME_FORMATTER.format(date) : "");

	}

	public String getShowProfileAlias() {

		if (userProfileProvider != null) {

			return userProfileProvider.getShowProfileAlias();
		}

		return null;
	}

	@Override
	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = super.createDocument(req, uriParser, user);

		if (CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))) {
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "hasAddContentAccess", true);
		}

		return doc;
	}

	public void appendUserSections(Document doc, Element element, HttpServletRequest req, User user) {	}

	public abstract List<CalendarPost> getPosts(Timestamp startDate, Timestamp endDate, HttpServletRequest req, User user) throws SQLException;

	public abstract List<CalendarPost> getPosts(Timestamp date, HttpServletRequest req, User user) throws SQLException;

	public void checkCRUDSupport(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {	}
}
