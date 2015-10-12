package se.sundsvall.collaborationroom.modules.calendar.beans;

import java.io.InputStream;
import java.util.List;

import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.unlogic.standardutils.date.PooledSimpleDateFormat;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.standardutils.time.TimeUtils;


public class CalendarPostSearchableItem implements CBSearchableItem {

	private static final PooledSimpleDateFormat LONG_DATE_FORMAT = new PooledSimpleDateFormat("EEEE dd MMMM yyyy HH:mm");
	private static final PooledSimpleDateFormat SHORT_DATE_FORMAT = new PooledSimpleDateFormat("EEEE dd MMMM yyyy");
	
	private final CalendarPost post;
	private final String alias;

	public CalendarPostSearchableItem(CalendarPost post, String alias) {

		super();
		this.post = post;
		this.alias = alias;
	}

	@Override
	public String getTitle() {

		return post.getTitle();
	}


	@Override
	public String getAlias() {

		return alias;
	}

	@Override
	public String getID() {

		return post.getPostID().toString();
	}

	@Override
	public String getInfoLine() {

		String date = LONG_DATE_FORMAT.format(post.getStartTime());
		
		if(date.startsWith(SHORT_DATE_FORMAT.format(post.getEndTime()))) {
			
			//Same day event
			date = StringUtils.toSentenceCase(date) + "-" + TimeUtils.TIME_FORMATTER.format(post.getEndTime());
			
		}else{
			
			date = StringUtils.toSentenceCase(date) + " - " + StringUtils.toSentenceCase(LONG_DATE_FORMAT.format(post.getEndTime()));
		}
		
		if(!StringUtils.isEmpty(post.getLocation())){
			
			date = date + " · " + post.getLocation();
		}
		
		return date;
	}

	@Override
	public String getContentType() {

		return "text/html";
	}

	@Override
	public InputStream getData() throws Exception {

		if(post.getDescription() != null) {
			
			return StringUtils.getInputStream(post.getDescription());
		
		}else{
			
			return StringUtils.getInputStream("");
		}
	}

	@Override
	public String getType() {

		return "calendar";
	}

	@Override
	public List<String> getTags() {

		return null;
	}
}
