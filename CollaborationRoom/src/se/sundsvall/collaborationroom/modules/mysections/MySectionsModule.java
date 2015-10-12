package se.sundsvall.collaborationroom.modules.mysections;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.CBConstants;
import se.dosf.communitybase.enums.SectionAccessMode;
import se.dosf.communitybase.interfaces.CBInterface;
import se.dosf.communitybase.modules.util.CBUtilityModule;
import se.dosf.communitybase.utils.CBAccessUtils;
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
import se.unlogic.hierarchy.foregroundmodules.AnnotatedForegroundModule;
import se.unlogic.standardutils.collections.CollectionUtils;
import se.unlogic.standardutils.dao.querys.ArrayListQuery;
import se.unlogic.standardutils.enums.EnumUtils;
import se.unlogic.standardutils.populators.IntegerPopulator;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.RequestUtils;
import se.unlogic.webutils.http.URIParser;

public class MySectionsModule extends AnnotatedForegroundModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Section load count", description = "The number of sections to load on the firstpage and each time more sections are requested")
	private Integer sectionLoadCount = 6;

	@InstanceManagerDependency(required = true)
	private CBInterface cbInterface;

	@InstanceManagerDependency(required = false)
	private CBUtilityModule cbUtilityModule;


	@Override
	public void init(ForegroundModuleDescriptor moduleDescriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(moduleDescriptor, sectionInterface, dataSource);

		if (!systemInterface.getInstanceHandler().addInstance(MySectionsModule.class, this)) {

			log.warn("Unable to register module " + moduleDescriptor + " in instance handler, another module is already registered for class " + MySectionsModule.class.getName());
		}
	}

	@Override
	public ForegroundModuleResponse defaultMethod(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Throwable {

		log.info("User " + user + " listing section instances");
		
		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("ListSections");
		doc.getFirstChild().appendChild(listPostsElement);
		
		Element mySectionsElement = XMLUtils.appendNewElement(doc, listPostsElement, "MySections");
		appendSections(doc, mySectionsElement, getUserSections(0, sectionLoadCount, user), true);
		
		if(!CBAccessUtils.isExternalUser(user)) {
			Element otherSectionsElement = XMLUtils.appendNewElement(doc, listPostsElement, "OtherSections");
			appendSections(doc, otherSectionsElement, getSections(0, sectionLoadCount, SectionAccessMode.OPEN), true);
		}
		
		return new SimpleForegroundModuleResponse(doc, getDefaultBreadcrumb());
	}

	@WebPublic(alias = "getsections")
	public ForegroundModuleResponse loadAdditionalSections(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser) throws Exception {

		Integer startIndex = uriParser.getInt(2);

		if (startIndex == null) {

			throw new URINotFoundException(uriParser);
		}

		SectionAccessMode sectionAccessMode = EnumUtils.toEnum(SectionAccessMode.class, uriParser.get(3));
		
		Document doc = createDocument(req, uriParser, user);
		Element listPostsElement = doc.createElement("LoadAdditionalSections");
		doc.getFirstChild().appendChild(listPostsElement);

		if(sectionAccessMode == null) {
			
			Element mySectionsElement = XMLUtils.appendNewElement(doc, listPostsElement, "MySections");
			appendSections(doc, mySectionsElement, getUserSections(startIndex, sectionLoadCount, user), true);
			
		} else {
			
			if(!CBAccessUtils.isExternalUser(user)) {
				Element otherSectionsElement = XMLUtils.appendNewElement(doc, listPostsElement, "OtherSections");
				appendSections(doc, otherSectionsElement, getSections(startIndex, sectionLoadCount, sectionAccessMode), true);
			}
		}
		
		SimpleForegroundModuleResponse moduleResponse = new SimpleForegroundModuleResponse(doc);

		moduleResponse.excludeSystemTransformation(true);

		return moduleResponse;
	}
	
	private List<SectionDescriptor> getSections(int startIndex, int sectionLoadCount, SectionAccessMode... sectionAccessMode) throws SQLException {
		
		ArrayListQuery<Integer> query = new ArrayListQuery<Integer>(this.dataSource, "SELECT s.sectionID FROM openhierarchy_sections s " +
				"INNER JOIN (SELECT sectionID, value FROM openhierarchy_section_attributes WHERE name = ? ) a ON s.sectionID = a.sectionID " +
				"LEFT OUTER JOIN (SELECT sectionID FROM openhierarchy_section_attributes WHERE name = ? ) d ON s.sectionID = d.sectionID " +
				"WHERE a.value IN(" + StringUtils.toQuotedCommaSeparatedString(sectionAccessMode) + ") AND s.enabled = 1 AND d.sectionID IS NULL " +
				"ORDER BY s.name LIMIT ?, ?", IntegerPopulator.getPopulator());
		
		query.setString(1, CBConstants.SECTION_ATTRIBUTE_ACCESS_MODE);
		query.setString(2, CBConstants.SECTION_ATTRIBUTE_DELETED);
		query.setInt(3, startIndex);
		query.setInt(4, sectionLoadCount);
		
		List<Integer> sectionIDs = query.executeQuery();

		if (sectionIDs != null) {

			List<SectionDescriptor> sections = new ArrayList<SectionDescriptor>(sectionIDs.size());

			for (Integer sectionID : sectionIDs) {
				SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

				if (sectionInterface != null) {
					sections.add(sectionInterface.getSectionDescriptor());
				}
			}
			
			return sections;
		}

		return null;
	}
	
	private List<SectionDescriptor> getUserSections(int startIndex, int sectionLoadCount, User user) throws SQLException {
		
		List<Integer> userSectionIDs = CBAccessUtils.getUserSections(user);
		
		if (!CollectionUtils.isEmpty(userSectionIDs)) {

			ArrayListQuery<Integer> query = new ArrayListQuery<Integer>(this.dataSource, "SELECT s.sectionID FROM openhierarchy_sections s " +
					"LEFT OUTER JOIN (SELECT sectionID FROM openhierarchy_section_attributes WHERE name = ? ) d ON s.sectionID = d.sectionID " +
					"WHERE s.sectionID IN(" + StringUtils.toQuotedCommaSeparatedString(userSectionIDs) + ") AND s.enabled = 1 AND d.sectionID IS NULL " +
					"ORDER BY s.name LIMIT ?, ?", IntegerPopulator.getPopulator());

			query.setString(1, CBConstants.SECTION_ATTRIBUTE_DELETED);
			query.setInt(2, startIndex);
			query.setInt(3, sectionLoadCount);

			List<Integer> sectionIDs = query.executeQuery();

			if (!CollectionUtils.isEmpty(sectionIDs)) {

				List<SectionDescriptor> sections = new ArrayList<SectionDescriptor>(sectionIDs.size());

				for (Integer sectionID : sectionIDs) {
					SectionInterface sectionInterface = systemInterface.getSectionInterface(sectionID);

					if (sectionInterface != null) {
						sections.add(sectionInterface.getSectionDescriptor());
					}
				}

				return sections;
			}
		}
		
		return null;
	}

	private void appendSections(Document doc, Element targetElement, List<SectionDescriptor> sectionDescriptors, boolean appendMembersCount) {

		if (sectionDescriptors != null) {

			for (SectionDescriptor sectionDescriptor : sectionDescriptors) {

				Element sectionElement = sectionDescriptor.toXML(doc);

					if (appendMembersCount) {
						
					List<Integer> members = cbInterface.getSectionMembers(sectionDescriptor.getSectionID());
					
						if(!CollectionUtils.isEmpty(members)) {
							XMLUtils.appendNewElement(doc, sectionElement, "membersCount", members.size());
						} else {
							XMLUtils.appendNewElement(doc, sectionElement, "membersCount", 0);
						}
						
					}

					targetElement.appendChild(sectionElement);
			}

		}

	}

	public Document createDocument(HttpServletRequest req, URIParser uriParser, User user) {

		Document doc = XMLUtils.createDomDocument();

		Element document = doc.createElement("Document");
		document.appendChild(RequestUtils.getRequestInfoAsXML(doc, req, uriParser));
		document.appendChild(this.moduleDescriptor.toXML(doc));
		document.appendChild(this.sectionInterface.getSectionDescriptor().toXML(doc));

		if(cbUtilityModule != null) {
			XMLUtils.appendNewElement(doc, document, "CBUtilityModuleAlias", cbUtilityModule.getFullAlias());
		}
		
		if (user != null) {
			document.appendChild(user.toXML(doc));
		}

		doc.appendChild(document);

		return doc;
	}
	
	@Override
	public void unload() throws Exception {

		systemInterface.getInstanceHandler().removeInstance(MySectionsModule.class, this);

		super.unload();
	}

}
