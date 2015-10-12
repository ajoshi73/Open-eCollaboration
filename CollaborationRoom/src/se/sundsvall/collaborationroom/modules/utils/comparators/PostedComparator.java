package se.sundsvall.collaborationroom.modules.utils.comparators;

import java.util.Comparator;

import se.dosf.communitybase.interfaces.Posted;


public class PostedComparator implements Comparator<Posted> {

	@Override
	public int compare(Posted o1, Posted o2) {

		return o2.getPosted().compareTo(o1.getPosted());
	}

}
