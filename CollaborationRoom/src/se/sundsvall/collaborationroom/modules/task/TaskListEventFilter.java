package se.sundsvall.collaborationroom.modules.task;

import se.dosf.communitybase.beans.SectionEvent;
import se.dosf.communitybase.beans.TransformedSectionEvent;
import se.dosf.communitybase.modules.sectionevents.EventFilter;
import se.sundsvall.collaborationroom.modules.task.beans.Task;
import se.sundsvall.collaborationroom.modules.task.beans.TaskList;


public class TaskListEventFilter implements EventFilter {

	private final Integer taskListID;
	
	public TaskListEventFilter(TaskList taskList) {

		this.taskListID = taskList.getTaskListID();
	}
	
	@SuppressWarnings("rawtypes")
	@Override
	public boolean deleteEvent(SectionEvent sectionEvent) {

		if(sectionEvent instanceof TransformedSectionEvent){
			
			Object bean = ((TransformedSectionEvent)sectionEvent).getBean();
			
			if(bean instanceof Task){
				
				TaskList taskList = ((Task)bean).getTaskList();
				
				if(taskList != null && taskList.getTaskListID().equals(taskListID)){
					
					return true;
				}
			}
		}
		
		return false;
	}
}
