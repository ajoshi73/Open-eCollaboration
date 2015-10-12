package se.sundsvall.collaborationroom.modules.filearchive;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.modules.sectionevents.EventFilter;
import se.sundsvall.collaborationroom.modules.filearchive.beans.Category;
import se.sundsvall.collaborationroom.modules.filearchive.beans.File;


public class CategoryEventFilter implements EventFilter {

	private final Integer categoryID;

	public CategoryEventFilter(Category category) {

		this.categoryID = category.getCategoryID();
	}

	@SuppressWarnings("rawtypes")
	@Override
	public boolean deleteEvent(SectionEvent sectionEvent) {

		if(sectionEvent instanceof TransformedSectionEvent){

			Object bean = ((TransformedSectionEvent)sectionEvent).getBean();

			if(bean instanceof File){

				Category category = ((File)bean).getCategory();

				if(category != null && category.getCategoryID().equals(categoryID)){

					return true;
				}
			}
		}

		return false;
	}
}
