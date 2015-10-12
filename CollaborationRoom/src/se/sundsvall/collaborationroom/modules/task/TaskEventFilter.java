package se.sundsvall.collaborationroom.modules.task;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.modules.sectionevents.EventFilter;
import se.sundsvall.collaborationroom.modules.task.beans.Task;


public class TaskEventFilter implements EventFilter {

	private final Integer taskID;

	public TaskEventFilter(Task task) {

		this.taskID = task.getTaskID();
	}

	@SuppressWarnings("rawtypes")
	@Override
	public boolean deleteEvent(SectionEvent sectionEvent) {

		if(sectionEvent instanceof TransformedSectionEvent){

			Object bean = ((TransformedSectionEvent)sectionEvent).getBean();

			if(bean instanceof Task && ((Task)bean).getTaskID().equals(taskID)){

				return true;
			}
		}

		return false;
	}
}
