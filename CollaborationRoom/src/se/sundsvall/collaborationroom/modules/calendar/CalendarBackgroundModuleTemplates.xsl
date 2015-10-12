<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
		/jquery/jquery-migrate.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/calendarbackgroundmodule.js
	</xsl:variable>

	<xsl:template match="Document">
		
		<div class="contentitem of-module">
			
			<xsl:apply-templates select="ShowMiniMonthCalendar" />
			
		</div>
		
	</xsl:template>

	<xsl:template match="ShowMiniMonthCalendar">
		
		<section class="of-calendar of-block of-widget">
		<script type="text/javascript">
			var ofCalendarInitialEvents = jQuery.parseJSON('<xsl:value-of select="initialPosts" />'),
			ofCalendarTodaysEvents = jQuery.parseJSON('[]');
			ofCalendarAjaxUrl = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/getposts';
		</script>
		
			<script id="of-calendar-widget-template" type="text/x-handlebars-template">	
				<header>
				<h3><xsl:value-of select="/Document/module/name" /></h3>
			</header>
			
				<div class="month clndr-controls">
				<a class="prev-month clndr-previous-button of-icon of-icon-only" href="#">
					<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#arrow-left"></use></svg></i>
					<span><xsl:value-of select="$i18n.PreviousMonth" /></span>
				</a>
				<h2>{{month}} {{year}}</h2>
				<a class="next-month clndr-next-button of-icon of-icon-only" href="#">
					<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#arrow-right"></use></svg></i>
					<span><xsl:value-of select="$i18n.NextMonth" /></span>
				</a>
			</div>
		
			<div class="days of-inner-padded-rl-half">
				<ul>
					<li class="header">V</li>
					{{#each daysOfTheWeek}}
					<li class="header">{{safe_string this}}</li>
					{{/each}}
		
					{{#widget_list days}}
						{{this}}
					{{/widget_list}}
		
				</ul>
			</div>
		
			<article class="day of-inner-padded-trl-half of-feed-list-scroll">
				<ul class="of-feed-list">
					{{currentEvents this/currentEvents}}
				</ul>
			</article>
		
			<xsl:if test="/Document/hasAddContentAccess">
				<footer>
					<a class="of-block-link of-icon of-icon-md" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}#add-calendar-post">
						<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#plus"></use></svg></i>
						<span><xsl:value-of select="$i18n.AddPost" /></span>
					</a>
				</footer>
			</xsl:if>
			
		</script>
	
	</section>
	
	</xsl:template>
	
</xsl:stylesheet>