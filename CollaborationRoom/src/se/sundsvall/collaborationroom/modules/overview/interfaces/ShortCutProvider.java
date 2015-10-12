package se.sundsvall.collaborationroom.modules.overview.interfaces;

import java.util.List;

import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.unlogic.hierarchy.core.beans.User;


public interface ShortCutProvider {

	public List<ShortCut> getShortCuts(User user);
	
}
