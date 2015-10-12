package se.sundsvall.collaborationroom.modules.task.beans;

import java.util.Calendar;
import java.util.concurrent.TimeUnit;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.sundsvall.collaborationroom.modules.task.enums.TaskState;
import se.unlogic.standardutils.xml.ElementableListener;
import se.unlogic.standardutils.xml.XMLUtils;

public class TaskElementableListener implements ElementableListener<Task> {

	private int deadlineThreshold = 3;

	private long todayTime;

	private long thisWeekStartTime;
	private long thisWeekEndTime;

	private long nextWeekStartTime;
	private long nextWeekEndTime;

	public TaskElementableListener() {
		
		Calendar calendar = Calendar.getInstance();

		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);

		this.todayTime = calendar.getTimeInMillis();

		calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

		this.thisWeekStartTime = calendar.getTimeInMillis();

		calendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);

		this.thisWeekEndTime = calendar.getTimeInMillis();

		calendar.add(Calendar.WEEK_OF_YEAR, 1);
		calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

		this.nextWeekStartTime = calendar.getTimeInMillis();

		calendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);

		this.nextWeekEndTime = calendar.getTimeInMillis();
		
	}
	
	public TaskElementableListener(int deadlineThreshold) {

		this();
		
		this.deadlineThreshold = deadlineThreshold;
	}

	@Override
	public void elementGenerated(Document doc, Element element, Task task) {

		Element taskStatesElement = doc.createElement("TaskStates");

		if (task.getFinished() != null) {

			XMLUtils.appendNewElement(doc, taskStatesElement, "TaskState", TaskState.FINISHED);

		} else {

			XMLUtils.appendNewElement(doc, taskStatesElement, "TaskState", TaskState.ACTIVE);

		}

		if (task.getDeadline() != null) {

			long deadline = task.getDeadline().getTime();
			long thresholdTime = deadline - TimeUnit.DAYS.toMillis(deadlineThreshold);

			if (todayTime > deadline) {

				XMLUtils.appendNewElement(doc, taskStatesElement, "TaskState", TaskState.MISSEDDEADLINE);

			} else if (thresholdTime <= todayTime) {

				XMLUtils.appendNewElement(doc, taskStatesElement, "TaskState", TaskState.NEARDEADLINE);

			}

			if (deadline >= thisWeekStartTime && deadline <= thisWeekEndTime) {

				XMLUtils.appendNewElement(doc, taskStatesElement, "TaskState", TaskState.WEEKDEADLINE);

			} else if (deadline >= nextWeekStartTime && deadline <= nextWeekEndTime) {

				XMLUtils.appendNewElement(doc, taskStatesElement, "TaskState", TaskState.NEXTWEEKDEADLINE);
			}

		}

		element.appendChild(taskStatesElement);
		
	}

	
	public int getDeadlineThreshold() {
	
		return deadlineThreshold;
	}

	
	public void setDeadlineThreshold(int deadlineThreshold) {
	
		this.deadlineThreshold = deadlineThreshold;
	}

}
