<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="LoadAdditionalTasks">
				<xsl:apply-templates select="LoadAdditionalTasks" />
			</xsl:when>
			<xsl:otherwise>
				
				<div class="contentitem of-module">
			
					<xsl:apply-templates select="MyTasks" />
					
					<script type="text/javascript">
						taskModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
						i18nTaskModule = {
							"FINISHED_BY": '<xsl:value-of select="$i18n.FinishedBy" />',
							"NEW_TASK": '<xsl:value-of select="$i18n.NewTask" />',
							"FINISH_TASK_ERROR": '<xsl:value-of select="$i18n.FinishTaskError" />'
						};
					</script>
					
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="MyTasks">
		
		<header class="of-inner-padded-trl">
			<h1><xsl:value-of select="/Document/module/name" /></h1>
		</header>
	
		<article class="of-inner-padded-rbl of-inner-padded-t-half">
		
			<xsl:choose>
				<xsl:when test="TaskList[tasks/Task[responsibleUser/userID = /Document/user/userID and not(finished)]]">
					
					<div>
						<select id="stateFilter" data-of-select="inline">
							<option selected="" value="AllWithoutFinished"><xsl:value-of select="$i18n.FilterOn" /></option>
							<optgroup label="{$i18n.Status}">
								<option value="ACTIVE"><xsl:value-of select="$i18n.Active" /></option>
								<option value="NEARDEADLINE"><xsl:value-of select="$i18n.NearDeadline" /></option>
								<option value="MISSEDDEADLINE"><xsl:value-of select="$i18n.MissedDeadline" /></option>
							</optgroup>
							<optgroup label="{$i18n.Deadline}">
								<option value="WEEKDEADLINE"><xsl:value-of select="$i18n.ThisWeek" /></option>
								<option value="NEXTWEEKDEADLINE"><xsl:value-of select="$i18n.NextWeek" /></option>
							</optgroup>
						</select>
					</div>
					
					<div id="taskListFilterNotice" style="display: none;">
							<div class="floatleft">
								<xsl:value-of select="$i18n.HiddenTaskListsPre" />
								<xsl:text>&#160;</xsl:text>
							</div>
							<span class="floatleft"/>
							<div class="floatleft">
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="$i18n.HiddenTaskListsPost" />
							</div>
						</div>
					
					<div class="of-inner-padded-b"/>
					
					<div data-of-toggled-multiple="list">
						<xsl:apply-templates select="TaskList[tasks/Task[responsibleUser/userID = /Document/user/userID and not(finished)]]" mode="active-list" />
						<xsl:apply-templates select="TaskModule" />
					</div>
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n.NoTaskLists" />
				</xsl:otherwise>
			</xsl:choose>
		
		</article>
	
	</xsl:template>
	
	<xsl:template match="TaskList">
		
		<a name="tasklist{taskListID}" />
		
		<xsl:variable name="sectionID" select="sectionID" />
		
		<div data-tasklistid="{taskListID}" data-name="{name}" data-sectionid="{sectionID}">
		
			<xsl:variable name="taskModule" select="../TaskModule[sectionID = $sectionID]" />
			
			<header>
				<h3 class="no-padding-rl">
					<a href="{/Document/requestinfo/contextpath}{$taskModule/fullAlias}"><xsl:value-of select="$taskModule/sectionName" /></a>
					<xsl:text>:&#160;</xsl:text>
					<span><xsl:value-of select="name" /></span>
				</h3>
			</header>
			
			<div>
				
				<xsl:choose>
					<xsl:when test="tasks/Task[responsibleUser/userID = /Document/user/userID and not(finished)]">
						<ul class="of-todo-list" data-toggletaskalias="{/Document/requestinfo/contextpath}{$taskModule/fullAlias}/toggletask">
							<xsl:apply-templates select="tasks/Task[responsibleUser/userID = /Document/user/userID and not(finished)]" />
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<ul class="of-todo-list of-no-sort"><li class="bigmargintop"><xsl:value-of select="$i18n.NoTasks" /></li></ul>
					</xsl:otherwise>				
				</xsl:choose>
				
				<xsl:variable name="finishedTasksCount" select="count(tasks/Task[finished])" />
				
				<xsl:if test="$finishedTasksCount > 0">
					<a href="{/Document/requestinfo/contextpath}{$taskModule/fullAlias}/showtasklist/{taskListID}">
						<xsl:value-of select="$i18n.ShowFinished.Part1" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$finishedTasksCount" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.ShowFinished.Part2" />
					</a>
				</xsl:if>
				
			</div>
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="TaskModule">
	
		<div class="of-modal" data-of-modal="update-task-section-{sectionID}">
			
			<a href="#" data-of-close-modal="update-task-section-{sectionID}" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2 />
			</header>
			
			<form action="{/Document/requestinfo/contextpath}{fullAlias}/updatetask?redirectURI=/{/Document/module/alias}" method="post" class="of-form no-auto-scroll">

				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatetask'">
					<div class="validationerrors of-hidden" data-of-open-modal="update-task-section-{sectionID}">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'taskID'"/>
				</xsl:call-template>

				<div>
					
					<label class="of-block-label">
						<span><xsl:value-of select="$i18n.TaskList" /></span>
					</label>
					<div class="listnametext margintop marginleft"/>
					<xsl:call-template name="createHiddenField">
						<xsl:with-param name="name" select="'taskListID'"/>
					</xsl:call-template>
					
					<label data-of-required="" class="of-block-label">
						<span><xsl:value-of select="$i18n.Task" /></span>
						<xsl:call-template name="createTextField">
							<xsl:with-param name="name" select="'title'" />
						</xsl:call-template>
					</label>
					
					<label class="of-block-label">
						<span data-of-description="{$i18n.Optional}"><xsl:value-of select="$i18n.Description" /></span>
						<textarea name="description" data-of-no-resize="" rows="3">
							<xsl:choose>
								<xsl:when test="requestparameters/parameter[name = 'description']"><xsl:value-of select="requestparameters/parameter[name = 'description']/value" /></xsl:when>
								<xsl:otherwise><xsl:value-of select="description" /></xsl:otherwise>
							</xsl:choose>
						</textarea>
					</label>
	
					<label class="of-block-label">
						<span data-of-description="{$i18n.Optional}"><xsl:value-of select="$i18n.ChooseResponsible" /></span>
						<xsl:call-template name="createOFDropdown">
							<xsl:with-param name="id" select="'responsibleUser'"/>
							<xsl:with-param name="name" select="'responsibleUser'"/>
							<xsl:with-param name="valueElementName" select="'userID'" />
							<xsl:with-param name="labelElementName" select="'firstname'" />
							<xsl:with-param name="labelElementName2" select="'lastname'" />
							<xsl:with-param name="element" select="members/user"/>
							<xsl:with-param name="addEmptyOption" select="$i18n.NotAssigned"/>	
							<xsl:with-param name="showInline" select="false()"/>
						</xsl:call-template>
					</label>
	
					<label class="of-block-label">
						<span data-of-description="{$i18n.Optional}"><xsl:value-of select="$i18n.Deadline" /></span>
						<input type="date" name="deadline" />
					</label>
					
				</div>
	
				<footer class="of-text-right">
					<a href="#" class="submit-btn of-btn of-btn-inline of-btn-gronsta"><xsl:value-of select="$i18n.Save" /></a>
					<span class="of-btn-link">eller <a data-of-close-modal="update-task-section-{sectionID}" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
	</xsl:template>
	
</xsl:stylesheet>