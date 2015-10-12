package se.sundsvall.collaborationroom.modules.page.utils;

import java.util.Comparator;

import se.unlogic.hierarchy.core.interfaces.MenuItemDescriptor;


public class MenuItemDescriptorComparator implements Comparator<MenuItemDescriptor> {

	private static final MenuItemDescriptorComparator INSTANCE = new MenuItemDescriptorComparator();
	
	@Override
	public int compare(MenuItemDescriptor o1, MenuItemDescriptor o2) {

		return o1.getName().toLowerCase().compareTo(o2.getName().toLowerCase());
	}
	
	public static MenuItemDescriptorComparator getInstance() {
		
		return INSTANCE;
	}

}
