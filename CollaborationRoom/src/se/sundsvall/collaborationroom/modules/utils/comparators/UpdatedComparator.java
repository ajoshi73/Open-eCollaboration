package se.sundsvall.collaborationroom.modules.utils.comparators;

import java.util.Comparator;

import se.dosf.communitybase.beans.PostedBean;


public class UpdatedComparator implements Comparator<PostedBean> {

	@Override
	public int compare(PostedBean o1, PostedBean o2) {

		return o2.getUpdated().compareTo(o1.getUpdated());
	}

}
