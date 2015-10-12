package se.sundsvall.collaborationroom.modules.calendar;

import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.calendar.beans.CalendarPost;
import se.unlogic.hierarchy.core.annotations.HTMLEditorSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.MutableUser;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.AccessDeniedException;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.exceptions.UnableToUpdateUserException;
import se.unlogic.hierarchy.core.interfaces.AttributeHandler;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.MutableAttributeHandler;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.AccessUtils;
import se.unlogic.hierarchy.core.utils.HierarchyAnnotatedDAOFactory;
import se.unlogic.hierarchy.foregroundmodules.rest.AnnotatedRESTModule;
import se.unlogic.hierarchy.foregroundmodules.rest.RESTMethod;
import se.unlogic.hierarchy.foregroundmodules.rest.URIParam;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.date.DateUtils;
import se.unlogic.standardutils.random.RandomUtils;
import se.unlogic.webutils.http.URIParser;
import biweekly.Biweekly;
import biweekly.ICalendar;
import biweekly.component.VEvent;
import biweekly.property.DateEnd;
import biweekly.property.DateStart;
import biweekly.property.Description;
import biweekly.property.Location;
import biweekly.property.Summary;
import biweekly.util.Duration;


public class ICalModule extends AnnotatedRESTModule{
	
	@ModuleSetting
	@HTMLEditorSettingDescriptor(name = "iCal available message", description = "The message on the iCal information page when an iCal URL is available", required=true)
	private String icalAvailableMessage = "not set";
	
	@ModuleSetting
	@HTMLEditorSettingDescriptor(name = "iCal not available message", description = "The message on the iCal information page when no iCal URL is available", required=true)
	private String icalNotAvailableMessage = "not set";		
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name="Language", description="Language to set on generated ICS files", required=true)
	private String language ="sv-SE";
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name="Context path URL", description="The full URL to the contextpath of this module", required=true)
	private String contextPath ="not set";	
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name="Product Identifier", description="The Product Identifier to set in generated ICS files.", required=true)
	private String prodID ="-//Not set//NONSGML CommunityBase3//EN";	
	
	private AnnotatedDAO<CalendarPost> annotatedDAO;
	
	private QueryParameterFactory<CalendarPost, Integer> sectionParamFactory;	
	
	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);
		
		if (!systemInterface.getInstanceHandler().addInstance(ICalModule.class, this)) {

			log.warn("Unable to register module " + moduleDescriptor + " in instance handler, another module is already registered for class " + ICalModule.class.getName());
		}		
	}

	@Override
	public void unload() throws Exception {

		systemInterface.getInstanceHandler().removeInstance(ICalModule.class, this);		
		
		super.unload();
	}	
	
	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		annotatedDAO = new HierarchyAnnotatedDAOFactory(dataSource, systemInterface).getDAO(CalendarPost.class);
		
		sectionParamFactory = annotatedDAO.getParamFactory("sectionID", Integer.class);
	}

	@RESTMethod(alias="{token}", method="get")
	public void generateIcsFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, @URIParam(name="token") String token) throws Throwable{
		
		User tokenUser = systemInterface.getUserHandler().getUserByAttribute(CalendarConstants.USER_CALENDAR_TOKEN_ATTRIBUTE, token, true, true);
		
		if(tokenUser == null){
			
			throw new URINotFoundException(uriParser);
		}
		
		List<Integer> sectionIDs = CBAccessUtils.getUserSections(tokenUser);
		
		if(sectionIDs != null){
			
			Iterator<Integer> sectionIterator = sectionIDs.iterator();
			
			//Remove ID's of sections which are not started or where the calender module is not enabled
			while(sectionIterator.hasNext()){
				
				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionIterator.next());
				
				if(sectionInterface == null || sectionInterface.getForegroundModuleCache().getModuleEntryByClass(CalendarModule.class) == null){
					
					sectionIterator.remove();
					continue;
				}
			}
		}
		
		ICalendar ical = new ICalendar();
		ical.setProductId(prodID);
		
		if(!CollectionUtils.isEmpty(sectionIDs)){
			
			List<CalendarPost> posts = getCalendarPosts(sectionIDs);
			
			if(posts != null){
				
				appendPosts(ical, posts);
			}
		}
		
		sendCalendar(ical, tokenUser, tokenUser, res);
	}
	
	@RESTMethod(alias="{sectionID}/{token}", method="get")
	public void generateIcsFile(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, @URIParam(name="sectionID") Integer sectionID, @URIParam(name="token") String token) throws Throwable{
		
		User tokenUser = systemInterface.getUserHandler().getUserByAttribute(CalendarConstants.USER_CALENDAR_TOKEN_ATTRIBUTE, token, true, true);
		
		if(tokenUser == null){
			
			throw new URINotFoundException(uriParser);
		}
		
		SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);
		
		if(sectionInterface == null){
			
			throw new URINotFoundException(uriParser);
		}
		
		if(!AccessUtils.checkAccess(tokenUser, sectionInterface.getSectionDescriptor())){
			
			throw new AccessDeniedException("Tok user " + tokenUser + " does not have access to section " + sectionInterface.getSectionDescriptor() + " (logged in user " + user + ")");
		}
		
		log.info("Token user " + tokenUser + " downloading iCal data for calendar in section " + sectionID + " (logged in user " + user + ")");
		
		ICalendar ical = new ICalendar();
		ical.setProductId(prodID);
		
		//Check if the calendar module is enabled in this section
		if(sectionInterface.getForegroundModuleCache().getModuleEntryByClass(CalendarModule.class) != null){
			
			List<CalendarPost> posts = getCalendarPosts(sectionID);
			
			if(posts != null){
				
				appendPosts(ical, posts);
			}	
		}
		
		sendCalendar(ical, tokenUser, tokenUser, res);
	}

	private void appendPosts(ICalendar ical, List<CalendarPost> posts) {

		for(CalendarPost post : posts){
			
			VEvent event = new VEvent();
			
			event.setUid(post.getPostID().toString());

			Summary summary = event.setSummary(post.getTitle());
			summary.setLanguage(language);
			
			if(post.getLocation() != null){
				
				Location location = event.setLocation(post.getLocation());
				location.setLanguage(language);
			}
			
			event.setCreated(post.getPosted());
			
			//Workaround for whole day event bug in biweekly 0.3.3 and older
			if(post.isWholeDay()){
				
				event.setDateStart(new DateStart(post.getStartTime(), false));
				event.getDateStart().setRawComponents(null);
				
				int daysBetween = (int)DateUtils.daysBetween(post.getStartTime(), post.getEndTime());
				daysBetween++;
				
				event.setDuration(new Duration.Builder().days(daysBetween).build());
				
			}else{

				event.setDateStart(new DateStart(post.getStartTime(), true));
				event.setDateEnd(new DateEnd(post.getEndTime(), true));
			}
			
			if(post.getUpdated() != null){
				
				event.setLastModified(post.getUpdated());
				
			}else{
				
				event.setLastModified(post.getPosted());
			}

			if(event.getDescription() != null){

				Description description = event.setDescription(post.getDescription());
				description.setLanguage(language);
			}
			
			ical.addEvent(event);
		}
	}

	private void sendCalendar(ICalendar ical, User tokenUser, User user, HttpServletResponse res) {

		res.setContentType("text/calendar");
		res.setHeader("Content-Disposition", "inline; filename=\"calendar.ics\"");
		
		try {
			Biweekly.write(ical).go(res.getOutputStream());
		} catch (Exception e) {
			log.info("Error sending ICS file to token user " + tokenUser + ", logged in user " + user);
		}
	}

	private List<CalendarPost> getCalendarPosts(Integer sectionID) throws SQLException {

		HighLevelQuery<CalendarPost> query = new HighLevelQuery<CalendarPost>();
		
		query.addParameter(sectionParamFactory.getParameter(sectionID));
		
		return annotatedDAO.getAll(query);
	}
	
	private List<CalendarPost> getCalendarPosts(List<Integer> sectionIDs) throws SQLException {

		HighLevelQuery<CalendarPost> query = new HighLevelQuery<CalendarPost>();
		
		query.addParameter(sectionParamFactory.getWhereInParameter(sectionIDs));
		
		return annotatedDAO.getAll(query);
	}
	
	/**
	 * @return the URL to the users global calendar, null if no calendar token is available for this user
	 */
	public String getUserCalendarURL(User user){
		
		String token = getCalendarTokenAttribute(user);
		
		if(token == null){
			
			return null;
		}
		
		return this.contextPath + this.getFullAlias() + "/" + token;
	}
	
	/**
	 * @return the URL to the users calendar for the given section ID or null if no calendar token is available for this user
	 */
	public String getUserCalendarURL(User user, Integer sectionID){
		
		String token = getCalendarTokenAttribute(user);
		
		if(token == null){
			
			return null;
		}
		
		return this.contextPath + this.getFullAlias() + "/" + sectionID + "/" + token;
	}

	private String getCalendarTokenAttribute(User user) {

		if(user == null){
			
			return null;
		}

		synchronized(user){
		
			AttributeHandler attributeHandler = user.getAttributeHandler();
			
			if(attributeHandler == null){
				
				return null;
			}
			
			String token = attributeHandler.getString(CalendarConstants.USER_CALENDAR_TOKEN_ATTRIBUTE);
			
			if(token != null){
				
				return token;
			}
			
			if(user instanceof MutableUser && attributeHandler instanceof MutableAttributeHandler){
				
				token = user.getUserID() + "-" + RandomUtils.getRandomString(5, 5);
				
				((MutableAttributeHandler)attributeHandler).setAttribute(CalendarConstants.USER_CALENDAR_TOKEN_ATTRIBUTE, token);
				
				try {
					log.info("Adding calendar token to user " + user);
					
					systemInterface.getUserHandler().updateUser(user, false, false, true);
					
					return token;
					
				} catch (UnableToUpdateUserException e) {
					log.error("Error updating user " + user + " after adding calendar token attribute");
				}
			}			
		}
		
		return null;
	}

	
	public String getIcalAvailableMessage() {
	
		return icalAvailableMessage;
	}

	
	public String getIcalNotAvailableMessage() {
	
		return icalNotAvailableMessage;
	}	
}
