package se.sundsvall.collaborationroom.modules.filearchive;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.modules.sectionevents.EventFilter;
import se.sundsvall.collaborationroom.modules.filearchive.beans.File;


public class FileEventFilter implements EventFilter {

	private final Integer fileID;

	public FileEventFilter(File file) {

		this.fileID = file.getFileID();
	}

	@SuppressWarnings("rawtypes")
	@Override
	public boolean deleteEvent(SectionEvent sectionEvent) {

		if(sectionEvent instanceof TransformedSectionEvent){

			Object bean = ((TransformedSectionEvent)sectionEvent).getBean();

			if(bean instanceof File && ((File)bean).getFileID().equals(fileID)){

				return true;
			}
		}

		return false;
	}
}
