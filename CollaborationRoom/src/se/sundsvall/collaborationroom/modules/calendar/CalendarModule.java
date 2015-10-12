package se.sundsvall.collaborationroom.modules.calendar;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.enums.EventFormat;
import se.dosf.communitybase.events.CBSearchableItemAddEvent;
import se.dosf.communitybase.events.CBSearchableItemDeleteEvent;
import se.dosf.communitybase.events.CBSearchableItemUpdateEvent;
import se.dosf.communitybase.interfaces.CBSearchable;
import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.dosf.communitybase.interfaces.EventTransformer;
import se.dosf.communitybase.interfaces.SectionEventProvider;
import se.dosf.communitybase.modules.userprofile.UserProfileProvider;
import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.calendar.beans.CalendarPost;
import se.sundsvall.collaborationroom.modules.calendar.beans.CalendarPostSearchableItem;
import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.annotations.XSLVariable;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.enums.EventTarget;
import se.unlogic.hierarchy.core.interfaces.ViewFragment;
import se.unlogic.hierarchy.core.utils.SimpleViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.ViewFragmentTransformer;
import se.unlogic.hierarchy.core.utils.crud.BeanFilter;
import se.unlogic.standardutils.dao.AnnotatedDAO;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.LowLevelQuery;
import se.unlogic.standardutils.dao.MySQLRowLimiter;
import se.unlogic.standardutils.dao.OrderByCriteria;
import se.unlogic.standardutils.dao.QueryOperators;
import se.unlogic.standardutils.dao.QueryParameter;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.enums.Order;
import se.unlogic.standardutils.time.MillisecondTimeUnits;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class CalendarModule extends BaseCalendarModule implements EventTransformer<CalendarPost>, SectionEventProvider, BeanFilter<CalendarPost>, CBSearchable, ShortCutProvider {
	
	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Event stylesheet", description = "The stylesheet used to transform events")
	private String eventStylesheet = "CalendarEvent.sv.xsl";
	
	@XSLVariable(prefix = "java.")
	private String shortCutText = "Add calendarpost";
	
	protected AnnotatedDAO<CalendarPost> annotatedDAO;

	protected QueryParameterFactory<CalendarPost, Timestamp> postedParamFactory;
	
	protected QueryParameter<CalendarPost, Integer> sectionIDParameter;
	
	protected OrderByCriteria<CalendarPost> orderCriteria;

	private SimpleViewFragmentTransformer eventFragmentTransformer;
	
	@InstanceManagerDependency(required=false)
	protected UserProfileProvider userProfileProvider;	
	
	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		annotatedDAO = postDAO.getAnnotatedDAO();
		
		sectionIDParameter = annotatedDAO.getParamFactory("sectionID", Integer.class).getParameter(getSectionID());
		postedParamFactory = annotatedDAO.getParamFactory("posted", Timestamp.class);
		
		orderCriteria = annotatedDAO.getOrderByCriteria("posted", Order.DESC);

		postDAO.getGetQuery().addParameter(sectionIDParameter);
		postDAO.getGetAllQuery().addParameter(sectionIDParameter);

		this.postCRUD.addBeanFilter(this);
	}

	@Override
	protected void moduleConfigured() throws Exception {

		super.moduleConfigured();

		if(eventStylesheet == null){

			log.warn("No stylesheet set for event transformations");
			eventFragmentTransformer = null;

		}else{

			try{
				eventFragmentTransformer = new SimpleViewFragmentTransformer(eventStylesheet, systemInterface.getEncoding(), this.getClass(), moduleDescriptor, sectionInterface);

			}catch(Exception e){

				log.error("Error parsing stylesheet for event transformations",e);
				eventFragmentTransformer = null;
			}
		}
	}	
	
	@Override
	public List<CalendarPost> getPosts(Timestamp startDate, Timestamp endDate, HttpServletRequest req, User user) throws SQLException {

		HighLevelQuery<CalendarPost> query = new HighLevelQuery<CalendarPost>();

		query.addParameter(startDateParamFactory.getParameter(startDate, QueryOperators.BIGGER_THAN_OR_EUALS));
		query.addParameter(endDateParamFactory.getParameter(endDate, QueryOperators.SMALLER_THAN_OR_EUALS));
		query.addParameter(sectionIDParameter);

		return setCalendarPostAlias(postDAO.getAnnotatedDAO().getAll(query), req);
	}

	@Override
	public List<CalendarPost> getPosts(Timestamp date, HttpServletRequest req, User user) throws SQLException {

		LowLevelQuery<CalendarPost> query = new LowLevelQuery<CalendarPost>();

		query.setSql("SELECT * FROM " + this.postDAO.getAnnotatedDAO().getTableName() + " WHERE sectionID = ? AND (? BETWEEN startTime and endTime OR startTime < ? AND endTime >= ?)");

		query.addParameter(getSectionID());
		query.addParameter(date);
		query.addParameter(new Timestamp(date.getTime() + MillisecondTimeUnits.DAY));
		query.addParameter(date);

		return setCalendarPostAlias(postDAO.getAnnotatedDAO().getAll(query), req);
	}

	private List<CalendarPost> setCalendarPostAlias(List<CalendarPost> calendarPosts, HttpServletRequest req) {

		if (calendarPosts != null) {

			for (CalendarPost calendarPost : calendarPosts) {

				calendarPost.setFullAlias(getModuleURI(req) + "/show/" + calendarPost.getPostID());

			}

		}

		return calendarPosts;
	}

	@Override
	public List<SectionEvent> getEvents(Timestamp breakpoint, int count) throws Exception {

		HighLevelQuery<CalendarPost> query = new HighLevelQuery<CalendarPost>();
		
		query.addParameter(sectionIDParameter);
		
		if(breakpoint != null){
			
			query.addParameter(postedParamFactory.getParameter(breakpoint, QueryOperators.BIGGER_THAN));
		}
		
		query.addOrderByCriteria(orderCriteria);
		query.setRowLimiter(new MySQLRowLimiter(count));
		
		List<CalendarPost> calendarPosts = annotatedDAO.getAll(query);
		
		if(calendarPosts == null){
			
			return null;
		}
		
		List<SectionEvent> sectionEvents = new ArrayList<SectionEvent>(calendarPosts.size());
		
		for(CalendarPost post : calendarPosts){
			
			sectionEvents.add(getSectionEvent(post));
		}
		
		return sectionEvents;
	}
	
	private SectionEvent getSectionEvent(CalendarPost post) {

		return new TransformedSectionEvent<CalendarPost>(moduleDescriptor.getModuleID(), post.getPosted(), post, this, null);
	}
	
	@Override
	public ViewFragment getFragment(CalendarPost bean, EventFormat format, String fullContextPath, String eventType) throws Exception {

		ViewFragmentTransformer transformer = this.eventFragmentTransformer;

		if(transformer == null){

			log.warn("No event fragment transformer available, unable to transform event for calendar post " + bean);
			return null;
		}

		if(log.isDebugEnabled()){

			log.debug("Transforming event for calendar post " + bean);
		}

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		if(userProfileProvider != null) {

			XMLUtils.appendNewElement(doc, documentElement, "ContextPath", fullContextPath);

			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ProfileImageAlias", userProfileProvider.getProfileImageAlias());
			XMLUtils.appendNewElement(doc, doc.getDocumentElement(), "ShowProfileAlias", userProfileProvider.getShowProfileAlias());
		}

		XMLUtils.appendNewElement(doc, documentElement, "PostURL", fullContextPath + this.getFullAlias() + "/show/" + bean.getPostID());

		XMLUtils.appendNewElement(doc, documentElement, "Format", format);
		documentElement.appendChild(bean.toXML(doc));

		return transformer.createViewFragment(doc);
	}
	
	@Override
	public void beanLoaded(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {}

	@Override
	public void beansLoaded(List<? extends CalendarPost> beans, HttpServletRequest req, URIParser uriParser, User user) {}

	@Override
	public void addBean(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {}

	@Override
	public void beanAdded(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {

		if(sectionEventHandler != null){
			
			sectionEventHandler.addEvent(moduleDescriptor.getSectionID(), getSectionEvent(bean));
		}
		
		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemAddEvent(getSearchableItem(bean), moduleDescriptor), EventTarget.ALL);
	}

	@Override
	public void updateBean(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {}

	@Override
	public void beanUpdated(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {

		if(sectionEventHandler != null && eventFragmentTransformer != null){

			sectionEventHandler.replaceEvent(moduleDescriptor.getSectionID(), getSectionEvent(bean));
		}
		
		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemUpdateEvent(getSearchableItem(bean), moduleDescriptor), EventTarget.ALL);
	}

	@Override
	public void deleteBean(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {}

	@Override
	public void beanDeleted(CalendarPost bean, HttpServletRequest req, URIParser uriParser, User user) {

		if(sectionEventHandler != null){

			sectionEventHandler.removeEvent(moduleDescriptor.getSectionID(), getSectionEvent(bean));
		}
		
		systemInterface.getEventHandler().sendEvent(CBSearchableItem.class, new CBSearchableItemDeleteEvent(bean.getPostID().toString(), moduleDescriptor), EventTarget.ALL);
	}

	@Override
	public List<? extends CBSearchableItem> getSearchableItems() throws Exception {

		HighLevelQuery<CalendarPost> query = new HighLevelQuery<CalendarPost>();
		
		query.addParameter(sectionIDParameter);
		
		List<CalendarPost> calendarPosts = annotatedDAO.getAll(query);
		
		if(calendarPosts == null){
			
			return null;
		}
		
		List<CalendarPostSearchableItem> sectionEvents = new ArrayList<CalendarPostSearchableItem>(calendarPosts.size());
		
		for(CalendarPost post : calendarPosts){
			
			sectionEvents.add(getSearchableItem(post));
		}
		
		return sectionEvents;
	}
	
	private CalendarPostSearchableItem getSearchableItem(CalendarPost post) {

		return new CalendarPostSearchableItem(post, "/" + moduleDescriptor.getAlias() + "/show/" + post.getPostID());
	}

	@Override
	protected String getiCalURL(User user) {

		return iCalModule.getUserCalendarURL(user, moduleDescriptor.getSectionID());
	}
	
	@Override
	public List<ShortCut> getShortCuts(User user) {

		if(CBAccessUtils.hasAddContentAccess(user, cbInterface.getRole(getSectionID(), user))){
		
			return Collections.singletonList(new ShortCut(shortCutText, shortCutText, this.getFullAlias() + "#add"));
		
		}
		
		return null;
	}
	
}
