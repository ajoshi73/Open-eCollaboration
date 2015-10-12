package se.sundsvall.collaborationroom.modules.overview.beans;

import se.unlogic.standardutils.xml.GeneratedElementable;
import se.unlogic.standardutils.xml.XMLElement;

@XMLElement
public class ShortCut extends GeneratedElementable implements Comparable<ShortCut> {

	@XMLElement
	private String name;

	@XMLElement
	private String description;

	@XMLElement
	private String fullAlias;

	public ShortCut(String name, String description, String fullAlias) {

		this.name = name;
		this.description = description;
		this.fullAlias = fullAlias;
	}

	public String getName() {

		return name;
	}

	public void setName(String name) {

		this.name = name;
	}

	public String getDescription() {

		return description;
	}

	public void setDescription(String description) {

		this.description = description;
	}

	public String getFullAlias() {

		return fullAlias;
	}

	public void setFullAlias(String fullAlias) {

		this.fullAlias = fullAlias;
	}

	@Override
	public int compareTo(ShortCut other) {

		return name.toLowerCase().compareTo(other.getName().toLowerCase());
	}

}
