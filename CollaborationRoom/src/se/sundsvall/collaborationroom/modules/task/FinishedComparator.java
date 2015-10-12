package se.sundsvall.collaborationroom.modules.task;

import java.util.Comparator;

import se.sundsvall.collaborationroom.modules.task.beans.Task;


public class FinishedComparator implements Comparator<Task> {

	@Override
	public int compare(Task o1, Task o2) {

		return o2.getFinished().compareTo(o1.getFinished());
	}

}
