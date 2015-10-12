package se.sundsvall.collaborationroom.modules.calendar;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.utils.CBAccessUtils;
import se.sundsvall.collaborationroom.modules.calendar.beans.CalendarPost;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.exceptions.URINotFoundException;
import se.unlogic.hierarchy.core.interfaces.ForegroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.SectionDescriptor;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.dao.HighLevelQuery;
import se.unlogic.standardutils.dao.LowLevelQuery;
import se.unlogic.standardutils.dao.QueryOperators;
import se.unlogic.standardutils.dao.QueryParameterFactory;
import se.unlogic.standardutils.numbers.NumberUtils;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.MillisecondTimeUnits;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class UserCalendarModule extends BaseCalendarModule {

	protected QueryParameterFactory<CalendarPost, Integer> sectionIDParameterFactory;

	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		if (!systemInterface.getInstanceHandler().addInstance(UserCalendarModule.class, this)) {

			log.warn("Unable to register module " + moduleDescriptor + " in instance handler, another module is already registered for class " + UserCalendarModule.class.getName());
		}
	}
	
	@Override
	protected void createDAOs(DataSource dataSource) throws Exception {

		super.createDAOs(dataSource);

		sectionIDParameterFactory = postDAO.getAnnotatedDAO().getParamFactory("sectionID", Integer.class);

	}

	@Override
	public List<CalendarPost> getPosts(Timestamp startDate, Timestamp endDate, HttpServletRequest req, User user) throws SQLException {

		Map<Integer, String> aliasMap = getUserCalendarAliasMap(user, req);

		if (CollectionUtils.isEmpty(aliasMap)) {

			return null;
		}

		HighLevelQuery<CalendarPost> query = new HighLevelQuery<CalendarPost>();

		query.addParameter(startDateParamFactory.getParameter(startDate, QueryOperators.BIGGER_THAN_OR_EUALS));
		query.addParameter(endDateParamFactory.getParameter(endDate, QueryOperators.SMALLER_THAN_OR_EUALS));
		query.addParameter(sectionIDParameterFactory.getWhereInParameter(aliasMap.keySet()));

		return setCalendarPostAlias(postDAO.getAnnotatedDAO().getAll(query), aliasMap);

	}

	@Override
	public List<CalendarPost> getPosts(Timestamp date, HttpServletRequest req, User user) throws SQLException {

		Map<Integer, String> aliasMap = getUserCalendarAliasMap(user, req);

		if (CollectionUtils.isEmpty(aliasMap)) {

			return null;
		}

		LowLevelQuery<CalendarPost> query = new LowLevelQuery<CalendarPost>();

		query.setSql("SELECT * FROM " + this.postDAO.getAnnotatedDAO().getTableName() + " WHERE sectionID IN(" + StringUtils.toCommaSeparatedString(aliasMap.keySet()) + ") AND (? BETWEEN startTime and endTime OR startTime < ? AND endTime >= ?)");

		query.addParameter(date);
		query.addParameter(new Timestamp(date.getTime() + MillisecondTimeUnits.DAY));
		query.addParameter(date);

		return setCalendarPostAlias(postDAO.getAnnotatedDAO().getAll(query), aliasMap);

	}

	private Map<Integer, String> getUserCalendarAliasMap(User user, HttpServletRequest req) {

		List<Integer> sectionIDs = CBAccessUtils.getUserSections(user);

		if (sectionIDs != null) {

			Integer selectedSectionID = NumberUtils.toInt(req.getParameter("sectionID"));

			Map<Integer, String> map = new HashMap<Integer, String>();

			List<SectionDescriptor> sectionDescriptors = new ArrayList<SectionDescriptor>(sectionIDs.size());

			for (Integer sectionID : sectionIDs) {

				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

				if (sectionInterface != null) {

					Entry<ForegroundModuleDescriptor, CalendarModule> calendarModuleEntry = sectionInterface.getForegroundModuleCache().getModuleEntryByClass(CalendarModule.class);

					if (calendarModuleEntry != null) {

						if (selectedSectionID == null || (selectedSectionID != null && sectionID.equals(selectedSectionID))) {

							map.put(sectionID, req.getContextPath() + calendarModuleEntry.getValue().getFullAlias());

						}

						sectionDescriptors.add(sectionInterface.getSectionDescriptor());
					}

				}

			}

			req.setAttribute("userSections", sectionDescriptors);

			return map;

		}

		return null;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void appendUserSections(Document doc, Element element, HttpServletRequest req, User user) {

		List<SectionDescriptor> sectionDescriptors = (List<SectionDescriptor>) req.getAttribute("userSections");

		if (sectionDescriptors != null) {

			Element sectionsElement = XMLUtils.appendNewElement(doc, element, "UserSections");

			Integer selectedSectionID = NumberUtils.toInt(req.getParameter("sectionID"));

			for (SectionDescriptor sectionDescriptor : sectionDescriptors) {

				Element sectionElement = XMLUtils.appendNewElement(doc, sectionsElement, "Section");
				XMLUtils.appendNewElement(doc, sectionElement, "sectionID", sectionDescriptor.getSectionID());
				XMLUtils.appendNewElement(doc, sectionElement, "name", sectionDescriptor.getName());

				if (selectedSectionID != null && selectedSectionID.equals(sectionDescriptor.getSectionID())) {
					XMLUtils.appendNewElement(doc, sectionElement, "selected", true);
				}

			}

		}

	}

	private List<CalendarPost> setCalendarPostAlias(List<CalendarPost> calendarPosts, Map<Integer, String> aliasMap) {

		if (calendarPosts != null) {

			for (CalendarPost calendarPost : calendarPosts) {

				calendarPost.setFullAlias(aliasMap.get(calendarPost.getSectionID()) + "/show/" + calendarPost.getPostID());
				calendarPost.setSectionName(systemInterface.getSectionInterface(calendarPost.getSectionID()).getSectionDescriptor().getName());
				
			}

		}

		return calendarPosts;
	}

	@Override
	public void checkCRUDSupport(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		throw new URINotFoundException(uriParser);
	}

	@Override
	public void unload() throws Exception {

		systemInterface.getInstanceHandler().removeInstance(UserCalendarModule.class, this);

		super.unload();
	}

	@Override
	protected String getiCalURL(User user) {

		return iCalModule.getUserCalendarURL(user);
	}

}
