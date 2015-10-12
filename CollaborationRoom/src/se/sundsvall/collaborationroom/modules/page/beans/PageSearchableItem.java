package se.sundsvall.collaborationroom.modules.page.beans;

import java.io.InputStream;
import java.util.List;

import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.unlogic.standardutils.string.StringUtils;


public class PageSearchableItem implements CBSearchableItem {

	private final Page page;
	private final String alias;

	public PageSearchableItem(Page page, String alias) {

		super();
		this.page = page;
		this.alias = alias;
	}

	@Override
	public String getTitle() {

		return page.getTitle();
	}


	@Override
	public String getAlias() {

		return alias;
	}

	@Override
	public String getID() {

		return page.getPageID().toString();
	}

	@Override
	public String getInfoLine() {

		return null;
	}

	@Override
	public String getContentType() {

		return "text/html";
	}

	@Override
	public InputStream getData() throws Exception {

		if(page.getContent() != null) {
		
			return StringUtils.getInputStream(page.getContent());
		
		}else{
			
			return StringUtils.getInputStream("");
		}
	}

	@Override
	public String getType() {

		return "page";
	}

	@Override
	public List<String> getTags() {

		return null;
	}
}
