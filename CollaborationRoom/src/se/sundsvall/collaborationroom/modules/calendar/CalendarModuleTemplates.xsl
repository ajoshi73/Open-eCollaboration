<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="scriptPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/js</xsl:variable>
	<xsl:variable name="imagePath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/pics</xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
		/jquery/jquery-migrate.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/utils/js/common.js
		/js/timepicker/jquery.timepicker.js
		/js/calendarmodule.js
	</xsl:variable>

	<xsl:variable name="links">
		/js/timepicker/css/jquery.timepicker.css
	</xsl:variable>

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="LoadMoreDays">
				<xsl:apply-templates select="LoadMoreDays" />
			</xsl:when>
			<xsl:otherwise>
				
				<div class="contentitem of-module of-block">
			
					<script>
						calendarModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
					</script>
					
					<xsl:apply-templates select="ShowMonthCalendar" />
					<xsl:apply-templates select="ShowAgendaCalendar" />
					<xsl:apply-templates select="ShowCalendarPost" />
					<xsl:apply-templates select="ICalInfo" />
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="LoadMoreDays">
		
		<xsl:apply-templates select="Day" />
		
	</xsl:template>
	
	<xsl:template match="ShowMonthCalendar">
		
		<script type="text/javascript">
			var ofCalendarInitialEvents = jQuery.parseJSON('<xsl:value-of select="initialPosts" />'),
			ofCalendarTodaysEvents = jQuery.parseJSON('[]');
			ofCalendarAjaxUrl = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/getposts';
			ofCalendarAjaxBaseUrl = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/getposts'
		</script>
		
		<xsl:call-template name="createHeader" />
		
		<xsl:if test="/Document/hasAddContentAccess">
			<div data-of-toggled="add" class="of-border-bottom of-inner-padded of-hidden">
				<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=add" method="post" class="of-form">
					
					<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'add'">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
					
					<xsl:call-template name="createPostForm" />
				
					<div class="of-c-xs-2 of-omega">
						<div class="of-inner-padded-t-half">
							<button class="submit-btn of-btn of-btn-inline of-btn-gronsta of-right" type="button"><xsl:value-of select="$i18n.Add" /></button>
							<!--<div class="of-inline of-hide-to-md">
								<a data-of-open-modal="add-file" href="#" class="of-icon">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#file"/></svg></i><span>Bifoga fil</span>
								</a>
							</div>-->
						</div>
					</div>
				
				</form>
			</div>
		</xsl:if>
		
		<div class="of-calendar of-calendar-full of-block" id="monthCalendar">
		
			<script id="of-day-template" type="text/x-handlebars-template">	
				<div class="calendar-day">
					<header class="of-inner-padded-half">
						<h2>{{day}}</h2>
					</header>
			
					<article class="of-inner-padded-b-half">
						{{#eventsList events}}
							{{this}}
						{{/eventsList}}
					</article>
				</div>
			</script>
			
			<script id="of-calendar-template" type="text/x-handlebars-template">
				
				<div class="month clndr-controls of-inner-padded-rl of-inner-padded-tb-half">
					<div class="of-right-from-sm">
						<div class="of-btn-group">
							<a class="of-btn of-icon of-icon-only clndr-previous-button" href="#">
								<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#arrow-left"></use></svg></i>
								<span><xsl:value-of select="$i18n.PreviousMonth" /></span>
							</a>
							<a class="of-btn" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}?view=agenda"><xsl:value-of select="$i18n.Agenda" /></a>
							<a class="of-btn of-active" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}?view=month"><xsl:value-of select="$i18n.Month" /></a>
							<a class="of-btn of-icon of-icon-only clndr-next-button" href="#">
								<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#arrow-right"></use></svg></i>
								<span><xsl:value-of select="$i18n.NextMonth" /></span>
							</a>
						</div>
					</div>
					<h2 id="of-month-ph" class="of-has-btn-group of-month-name">{{month}} {{year}}</h2>
				</div>
	
				<div class="days of-inner-padded-rbl">
					<header class="calendar-row">
						<div>V</div>
						{{#each daysOfTheWeek}}
						<div>{{safe_string this}}</div>
						{{/each}}
					</header>
	
					{{#list days}}
						{{this}}
					{{/list}}
					<div class="calendar-day"></div>
				</div>
				
				<xsl:if test="ICalAvailable">
				
					<div class="of-inner-padded-rb of-inner-padded-t-half of-text-right">
						<a class="of-dark-link of-icon of-icon-xs" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/ical">
							<i>
								<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
									<use xlink:href="#calendar"/>
								</svg>
							</i>
							<span><xsl:value-of select="$i18n.SubscribeToCalendar"/></span>
						</a>
					</div>				
				
				</xsl:if>
			
			</script>
		
		</div>
	
	</xsl:template>
	
	<xsl:template name="createHeader">
	
		<xsl:param name="view" select="'month'" />
	
		<xsl:choose>
			<xsl:when test="UserSections/Section">
				
				<header class=" of-inner-padded-trl">
						<h1><xsl:value-of select="/Document/module/name" /></h1>
				</header>
				
				<div class="of-inner-padded-rl of-inner-padded-t-half">
					<xsl:call-template name="createOFDropdown">
						<xsl:with-param name="id" select="'sectionToggler'"/>
						<xsl:with-param name="name" select="'sectionID'"/>
						<xsl:with-param name="element" select="UserSections/Section"/>
						<xsl:with-param name="labelElementName" select="'name'" />
						<xsl:with-param name="valueElementName" select="'sectionID'" />
						<xsl:with-param name="addEmptyOption" select="$i18n.AllSections"/>
						<xsl:with-param name="selectedValue" select="UserSections/Section[selected]/sectionID" />
						<xsl:with-param name="class" select="$view"/>
					</xsl:call-template>
				</div>
				
			</xsl:when>
			<xsl:otherwise>
				
				<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
						<xsl:if test="/Document/hasAddContentAccess">
							<div class="of-right">
								<a class="of-btn of-btn-gronsta of-btn-xs of-btn-inline" href="#" data-of-toggler="add">
									<span><xsl:value-of select="$i18n.NewPost" /></span>
								</a>
							</div>
						</xsl:if>
					<h2><xsl:value-of select="/Document/module/name" /></h2>
				</header>
			
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="createPostForm">
		
		<xsl:param name="post" select="null" />
	
		<xsl:variable name="currentDate">
			
		</xsl:variable>
	
		<div class="of-c-xs-2 of-omega">
			<label data-of-required="" class="of-block-label">	
				<span><xsl:value-of select="$i18n.Title" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'title'"/>
					<xsl:with-param name="name" select="'title'"/>
					<xsl:with-param name="element" select="$post" />
				</xsl:call-template>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-omega">
			<label class="of-block-label">	
				<span><xsl:value-of select="$i18n.Location" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'location'"/>
					<xsl:with-param name="name" select="'location'"/>
					<xsl:with-param name="element" select="$post" />
				</xsl:call-template>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-omega">
			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.WholeDay" /></span>
				<select id="wholeDay" data-of-select="toggle" name="wholeDay">
					<option value="1">
						<xsl:if test="requestparameters/parameter[name = 'wholeDay']/value = '1' or $post/wholeDay = 'true'"><xsl:attribute name="selected"/></xsl:if>
						<xsl:value-of select="$i18n.Yes" />
					</option>
					<option value="0">
						<xsl:if test="requestparameters/parameter[name = 'wholeDay']/value = '0' or $post/wholeDay = 'false'  or not($post)"><xsl:attribute name="selected"/></xsl:if>
						<xsl:value-of select="$i18n.No" />
					</option>
				</select>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-c-lg-4 of-omega-xs of-omega-sm of-omega-md">
			<label data-of-required="" class="of-block-label">
				<span><xsl:value-of select="$i18n.StartDate" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'startDate'"/>
					<xsl:with-param name="name" select="'startDate'"/>
					<xsl:with-param name="type" select="'date'"/>
					<xsl:with-param name="element" select="$post" />
					<xsl:with-param name="value" select="currentDate" />
				</xsl:call-template>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-c-lg-4 of-omega">
			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.StartTime" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'startTime'"/>
					<xsl:with-param name="name" select="'startTime'"/>
					<xsl:with-param name="width" select="'100px'"/>
					<xsl:with-param name="element" select="$post" />
					<xsl:with-param name="value" select="currentTime" />
				</xsl:call-template>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-c-lg-4 of-omega-xs of-omega-sm of-omega-md clearboth">
			<label data-of-required="" class="of-block-label">
				<span><xsl:value-of select="$i18n.EndDate" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'endDate'"/>
					<xsl:with-param name="name" select="'endDate'"/>
					<xsl:with-param name="type" select="'date'"/>
					<xsl:with-param name="element" select="$post" />
					<xsl:with-param name="value" select="currentDate" />
				</xsl:call-template>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-c-lg-4 of-omega">
			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.EndTime" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'endTime'"/>
					<xsl:with-param name="name" select="'endTime'"/>
					<xsl:with-param name="width" select="'100px'"/>
					<xsl:with-param name="element" select="$post" />
					<xsl:with-param name="value" select="nextHourTime" />
				</xsl:call-template>
			</label>
		</div>
		
		<div class="of-c-xs-2 of-omega">
			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.Description" /></span>
				<div class="of-auto-resize-clone" style=""><br class="lbr" /></div>
				<xsl:call-template name="createTextArea">
					<xsl:with-param name="id" select="'updatepost_description'"/>
					<xsl:with-param name="name" select="'description'"/>
					<xsl:with-param name="class" select="'of-auto-resize'" />
					<xsl:with-param name="element" select="$post" />
				</xsl:call-template>
			</label>
		</div>
		
	</xsl:template>
	
	<xsl:template match="ShowCalendarPost">
		
		<xsl:variable name="postID" select="CalendarPost/postID" />
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			<div class="of-right">
				<a class="of-btn of-btn-outline of-btn-xs of-btn-inline of-icon of-icon-xs" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}">
					<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#arrow-left"></use></svg></i>
					<span><xsl:value-of select="$i18n.Back" /></span>
				</a>
				<xsl:if test="CalendarPost/hasUpdateAccess">
					<xsl:text>&#160;</xsl:text>
					<a class="of-btn of-btn-gronsta of-btn-xs of-btn-inline" href="#" data-of-toggler="edit-calendar-event">
						<span><xsl:value-of select="$i18n.Update" /></span>
					</a>
				</xsl:if>
			</div>
			<h2><xsl:value-of select="/Document/module/name" /></h2>
		</header>
		
		<xsl:if test="CalendarPost/hasUpdateAccess">
		
			<div class="of-border-bottom of-inner-padded of-hidden" data-of-toggled="edit-calendar-event">
				
				<form action="{/Document/requestinfo/uri}?method=update" method="post" class="of-form">
					
					<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'update'">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
					
					<xsl:call-template name="createPostForm">
						<xsl:with-param name="post" select="CalendarPost" />
					</xsl:call-template>
				
					<div class="of-c-xs-2 of-omega">
						<div class="of-inner-padded-t-half">
							<!--<div class="of-inline of-hide-to-md">
									<a data-of-open-modal="add-file" href="#" class="of-icon">
										<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#file"/></svg></i><span>Bifoga fil</span>
									</a>
								</div>-->
							<div class="of-inner-padded-t-half of-text-right">
								<button class="submit-btn of-btn of-btn-inline of-btn-gronsta" type="button"><xsl:value-of select="$i18n.Save" /></button>
								<span class="of-btn-link"><xsl:value-of select="$i18n.or" /><xsl:text>&#160;</xsl:text><a onclick="return confirm('{$i18n.DeletePostConfirm}: {title}?');" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/delete/{CalendarPost/postID}"><xsl:value-of select="$i18n.Delete" /></a></span>
							</div>
						</div>
					</div>
				
				</form>
				
			</div>
		
		</xsl:if>
		
		<article class="of-inner-padded-rbl of-inner-padded-t-half">
	
			<h2><xsl:value-of select="CalendarPost/title" /></h2>
			<ul class="of-meta-line">
				<li>
					<xsl:value-of select="$i18n.AddedBy" /><xsl:text>&#160;</xsl:text>
					<a href="{/Document/requestinfo/contextpath}{ShowProfileAlias}/{CalendarPost/poster/userID}">
						<xsl:call-template name="printUser">
							<xsl:with-param name="user" select="CalendarPost/poster" />
						</xsl:call-template>
					</a><xsl:text>,&#160;</xsl:text><xsl:value-of select="CalendarPost/formattedPostedDate" />
				</li>
				<xsl:if test="CalendarPost/formattedUpdatedDate">
					<xsl:value-of select="$i18n.UpdatedBy" /><xsl:text>&#160;</xsl:text>
					<a href="{/Document/requestinfo/contextpath}{ShowProfileAlias}/{CalendarPost/editor/userID}">
						<xsl:call-template name="printUser">
							<xsl:with-param name="user" select="CalendarPost/editor" />
						</xsl:call-template>
					</a><xsl:text>,&#160;</xsl:text><xsl:value-of select="CalendarPost/formattedUpdatedDate" />
				</xsl:if>
			</ul>
	
			<p>
				<strong><xsl:value-of select="$i18n.Starts" />:</strong><xsl:text>&#160;</xsl:text><xsl:value-of select="CalendarPost/formattedStartDate" /><br />
				<strong><xsl:value-of select="$i18n.Ends" />:</strong><xsl:text>&#160;</xsl:text><xsl:value-of select="CalendarPost/formattedEndDate" /><br />
				<strong><xsl:value-of select="$i18n.Location" />:</strong><xsl:text>&#160;</xsl:text>
				<xsl:choose>
					<xsl:when test="CalendarPost/location"><xsl:value-of select="CalendarPost/location" /></xsl:when>
					<xsl:otherwise>-</xsl:otherwise>
				</xsl:choose>
			</p>
	
			<p>
				<xsl:call-template name="replaceLineBreak">
					<xsl:with-param name="string" select="CalendarPost/description"/>
				</xsl:call-template>
			</p>
				
		</article>

		<xsl:if test="RelatedPosts/CalendarPost[postID != $postID]">
			
			<article class="of-inner-padded-rbl of-inner-padded-t-half of-border-top">
			
				<h2><xsl:value-of select="$i18n.MorePosts" /><xsl:text>&#160;</xsl:text><xsl:value-of select="formattedRelatedDate" /></h2>
				
				<ul class="of-feed-list of-inner-padded-t">
					<xsl:apply-templates select="RelatedPosts/CalendarPost[postID != $postID]" mode="list">
						<xsl:with-param name="date" select="relatedDate" />
					</xsl:apply-templates>
				</ul>
			
			</article>
			
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="CalendarPost" mode="list">
		
		<xsl:param name="date" />
		
		<li>
			
			<a href="{fullAlias}?date={$date}">
				<h5><xsl:value-of select="title" /></h5>
				<ul class="of-meta-line">
					<li>
						<xsl:choose>
							<xsl:when test="wholeDay = 'true'"><xsl:value-of select="$i18n.WholeDay" /></xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="startTime" />-<xsl:value-of select="endTime" />
							</xsl:otherwise>
						</xsl:choose>
					</li>
					<xsl:if test="location">
						<li><xsl:value-of select="location" /></li>
					</xsl:if>
					<xsl:if test="sectionName">
						<li><xsl:value-of select="sectionName" /></li>
					</xsl:if>
				</ul>
			</a>
		</li>
		
	</xsl:template>
	
	<xsl:template match="ShowAgendaCalendar">
		
		<xsl:call-template name="createHeader">
			<xsl:with-param name="view" select="'agenda'" />
		</xsl:call-template>
		
		<xsl:if test="/Document/hasAddContentAccess">
			<div data-of-toggled="add" class="of-border-bottom of-inner-padded of-hidden">
				<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=add" method="post" class="of-form">
					
					<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'add'">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
					
					<xsl:call-template name="createPostForm" />
				
					<div class="of-c-xs-2 of-omega">
						<div class="of-inner-padded-t-half">
							<button class="submit-btn of-btn of-btn-inline of-btn-gronsta of-right" type="button"><xsl:value-of select="$i18n.Add" /></button>
							<!--<div class="of-inline of-hide-to-md">
								<a data-of-open-modal="add-file" href="#" class="of-icon">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#file"/></svg></i><span>Bifoga fil</span>
								</a>
							</div>-->
						</div>
					</div>
				
				</form>
			</div>
		</xsl:if>
		
		<div class="agenda-controls month clndr-controls of-inner-padded-rl of-inner-padded-tb-half">
			<div class="of-right-from-sm">
				<div class="of-btn-group">
					<a href="#" class="of-btn of-icon of-icon-only clndr-previous-button disabled">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#arrow-left"/></svg></i>
						<span><xsl:value-of select="$i18n.PreviousMonth" /></span>
					</a>
					<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}?view=agenda" class="of-btn of-active"><xsl:value-of select="$i18n.Agenda" /></a>
					<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}?view=month" class="of-btn"><xsl:value-of select="$i18n.Month" /></a>
					<a href="#" class="of-btn of-icon of-icon-only clndr-next-button disabled">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#arrow-right"/></svg></i>
						<span><xsl:value-of select="$i18n.NextMonth" /></span>
					</a>
				</div>
			</div>
		</div>
		
		<xsl:choose>
			<xsl:when test="Day">
				
				<xsl:apply-templates select="Day" />
				
				<footer>
					<a id="showMoreLink" href="#" class="of-block-link">
						<span><xsl:value-of select="$i18n.ShowMore" /></span>
					</a>
				</footer>
				
			</xsl:when>
			<xsl:otherwise>
				<header class="day of-inner-padded-rl of-inner-padded-t-half">
					<h2 class="of-has-btn-group"><xsl:value-of select="$i18n.NoPosts" /></h2>
				</header>
			</xsl:otherwise>
		</xsl:choose>
		
		
		
	</xsl:template>
	
	<xsl:template match="Day">
		
		<header class="of-inner-padded-rl of-inner-padded-t-half">
			<h2 class="of-has-btn-group"><xsl:value-of select="formattedDate" /></h2>
		</header>
		
		<article class="day of-inner-padded-rl of-inner-padded-t-half" data-date="{date}">
			<ul class="of-feed-list">
				<xsl:apply-templates select="CalendarPost" mode="list">
					<xsl:with-param name="date" select="date" />
				</xsl:apply-templates>
			</ul>
		</article>
		
	</xsl:template>
	
	<xsl:template match="ICalInfo">
	
		<xsl:value-of select="Message" disable-output-escaping="yes"/>
	
		<div class="of-inner-padded-rbl">
			<xsl:if test="ICalURL">
				<a href="{ICalURL}"><xsl:value-of select="ICalURL"/></a>
			</xsl:if>		
		</div>
	
	</xsl:template>
	
	<xsl:template name="printUser">
		
		<xsl:param name="user" />
		
		<xsl:choose>
			<xsl:when test="$user"><xsl:value-of select="$user/firstname" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$user/lastname" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$i18n.DeletedUser" /></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="validationError">
		
		<xsl:if test="fieldName and validationErrorType">
			
			<span class="validationerror" data-parameter="{fieldName}">
				<span class="description error" >
					<xsl:choose>
						<xsl:when test="validationErrorType='RequiredField'">
							<xsl:value-of select="$i18n.validationError.RequiredField" />
						</xsl:when>
						<xsl:when test="validationErrorType='InvalidFormat'">
							<xsl:value-of select="$i18n.validationError.InvalidFormat" />
						</xsl:when>
						<xsl:when test="validationErrorType='TooShort'">
							<xsl:value-of select="$i18n.validationError.TooShort" />
						</xsl:when>
						<xsl:when test="validationErrorType='TooLong'">
							<xsl:value-of select="$i18n.validationError.TooLong" />
						</xsl:when>
						<xsl:when test="validationErrorType='Other'">
							<xsl:value-of select="$i18n.validationError.Other" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$i18n.validationError.unknownValidationErrorType" />
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#error"/></svg></i>
			</span>
		</xsl:if>
		<xsl:if test="messageKey">
			
				<xsl:choose>
					<xsl:when test="messageKey='DaysBetweenToSmall'">
						<span class="validationerror" data-parameter="endDate">
							<span class="description error" >
								<xsl:value-of select="$i18n.validationError.DaysBetweenToSmall" />
							</span>
						</span>
					</xsl:when>
					<xsl:when test="messageKey='EndTimeBeforeStartTime'">
						<span class="validationerror" data-parameter="endTime">
							<span class="description error" >
								<xsl:value-of select="$i18n.validationError.EndTimeBeforeStartTime" />
							</span>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<p class="error"><xsl:value-of select="$i18n.validationError.unknownMessageKey" />!</p>
					</xsl:otherwise>
				</xsl:choose>
				
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#error"/></svg></i>
		</xsl:if>
		<xsl:apply-templates select="message" />
		
	</xsl:template>
	
</xsl:stylesheet>