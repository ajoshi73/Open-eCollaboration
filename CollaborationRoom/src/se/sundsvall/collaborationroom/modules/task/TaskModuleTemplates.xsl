<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="scriptPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/js</xsl:variable>
	<xsl:variable name="imagePath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/pics</xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/utils/js/common.js
		/js/taskmodule.js
	</xsl:variable>

	<xsl:variable name="links">
	</xsl:variable>

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="LoadAdditionalTasks">
			
				<xsl:apply-templates select="LoadAdditionalTasks" />
				
			</xsl:when>
			<xsl:otherwise>
				
				<div id="TaskModule" class="contentitem of-module of-block">
			
					<xsl:apply-templates select="ListTaskLists" />
					<xsl:apply-templates select="ShowTaskList" />
					
					<script type="text/javascript">
						taskModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
						i18nTaskModule = {
							"FINISHED_BY": '<xsl:value-of select="$i18n.FinishedBy" />',
							"NEW_TASK": '<xsl:value-of select="$i18n.NewTask" />',
							"FINISH_TASK_ERROR": '<xsl:value-of select="$i18n.FinishTaskError" />',
							"FINISHED_TITLE": '<xsl:value-of select="$i18n.MarkAsFinished" />',
							"NOT_FINISHED_TITLE": '<xsl:value-of select="$i18n.MarkAsNotFinished" />',
							"CREATED_BY": '<xsl:value-of select="$i18n.AddedBy" />',
							"EDITED_BY": '<xsl:value-of select="$i18n.UpdatedBy" />',
							"FINISHED": '<xsl:value-of select="$i18n.Finished" />',
							"ACTIVE": '<xsl:value-of select="$i18n.Active" />'
						};
					</script>
					
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="LoadAdditionalTasks">
		
		<xsl:apply-templates select="Task" mode="compact" />
		
	</xsl:template>
	
	<xsl:template match="ListTaskLists">
	
		<xsl:if test="WithFinished">
			<script type="text/javascript">
				hasFinishedTasks = true;
			</script>
		</xsl:if>
		
		<xsl:if test="TaskListFilter">
			<script type="text/javascript">
				previousTaskListFilter = "<xsl:value-of select="TaskListFilter"/>";
			</script>
		</xsl:if>
		
		<xsl:if test="MembersFilter">
			<script type="text/javascript">
				previousMembersFilter = "<xsl:value-of select="MembersFilter"/>";
			</script>
		</xsl:if>
		
		<xsl:if test="StateFilter">
			<script type="text/javascript">
				previousStateFilter = "<xsl:value-of select="StateFilter"/>";
			</script>
		</xsl:if>
		
		<xsl:if test="TableSelected">
			<script type="text/javascript">
				tableSelected = true;
			</script>
		</xsl:if>
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			
			<xsl:if test="/Document/hasManageAccess">
				<div class="of-right">
					<a data-of-toggler="addtodolist" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline">
						<span><xsl:value-of select="$i18n.NewTaskList" /></span>
					</a>
				</div>
			</xsl:if>
			
			<h2><xsl:value-of select="/Document/module/name" /></h2>
		
		</header>
		
		<div class="of-border-bottom of-inner-padded of-hidden" data-of-toggled="addtodolist">
			
			<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=addtasklist" method="post" class="of-form">
				
				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'addtasklist'">		
					<div class="validationerrors of-hidden">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>
				
				<label data-of-required="" class="of-block-label">
					<span><xsl:value-of select="$i18n.TaskListName" /></span>
					<xsl:call-template name="createTextField">
						<xsl:with-param name="name" select="'name'" />
					</xsl:call-template>
				</label>
	
				<div class="of-text-right of-inner-padded-t-half">
					<button class="submit-btn of-btn of-btn-inline of-btn-gronsta" type="button"><xsl:value-of select="$i18n.Add" /></button>
				</div>
			</form>
			
		</div>
		
		<article class="of-inner-padded-rbl of-inner-padded-t-half">
			
			<xsl:choose>
				<xsl:when test="ActiveTaskLists/TaskList">
					
					<div>
						<select id="taskListFilter" data-of-select="inline">
							<option value=""><xsl:value-of select="$i18n.SortOnTaskList" /></option>
							
							<xsl:for-each select="ActiveTaskLists/TaskList">
								<option value="{taskListID}"><xsl:value-of select="name" /></option>
							</xsl:for-each>
						</select>
						
						<xsl:call-template name="createOFDropdown">
							<xsl:with-param name="id" select="'membersFilter'"/>
							<xsl:with-param name="name" select="'membersFilter'"/>
							<xsl:with-param name="valueElementName" select="'userID'" />
							<xsl:with-param name="labelElementName" select="'firstname'" />
							<xsl:with-param name="labelElementName2" select="'lastname'" />
							<xsl:with-param name="element" select="members/user"/>
							<xsl:with-param name="addEmptyOption" select="$i18n.AllMembers"/>	
						</xsl:call-template>
						
						<select id="stateFilter" data-of-select="inline">
							<option selected="" value="AllWithoutFinished"><xsl:value-of select="$i18n.ExcludeFinished" /></option>
							<option value=""><xsl:value-of select="$i18n.IncludeFinished" /></option>
							<optgroup label="{$i18n.Status}">
								<option value="ACTIVE"><xsl:value-of select="$i18n.ActiveMultiple" /></option>
								<option value="NEARDEADLINE"><xsl:value-of select="$i18n.NearDeadline" /></option>
								<option value="MISSEDDEADLINE"><xsl:value-of select="$i18n.MissedDeadline" /></option>
								<option value="FINISHED"><xsl:value-of select="$i18n.FinishedMultiple" /></option>
							</optgroup>
							<optgroup label="{$i18n.Deadline}">
								<option value="WEEKDEADLINE"><xsl:value-of select="$i18n.ThisWeek" /></option>
								<option value="NEXTWEEKDEADLINE"><xsl:value-of select="$i18n.NextWeek" /></option>
							</optgroup>
						</select>
						
						<div class="of-right">
							<div id="view-toggler" class="of-inline-block of-btn-group">
								<a class="of-btn of-icon of-icon-only of-active" href="#" data-of-toggler-multiple="list" title="{$i18n.ListTitle}">
									<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#list"></use></svg></i>
									<span><xsl:value-of select="$i18n.ListTitle" /></span>
								</a>
								<a class="of-btn of-icon of-icon-only" href="#" data-of-toggler-multiple="table" title="{$i18n.TableTitle}">
									<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#table"></use></svg></i>
									<span><xsl:value-of select="$i18n.TableTitle" /></span>
								</a>
							</div>
						</div>
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
					<div id="taskTableFilterNotice" class="" style="display: none;">
						<div class="floatleft">
							<xsl:value-of select="$i18n.HiddenTaskTablePre" />
							<xsl:text>&#160;</xsl:text>
						</div>
						<span class="floatleft"/>
						<div class="floatleft">
							<xsl:text>&#160;</xsl:text>
							<xsl:value-of select="$i18n.HiddenTaskTablePost" />
						</div>
					</div>
					
					<div class="of-inner-padded-b"/>
					
					<div data-of-toggled-multiple="list" data-toggletaskalias="{/Document/requestinfo/currentURI}/{/Document/module/alias}/toggletask">
						<xsl:apply-templates select="ActiveTaskLists/TaskList" mode="active-list" />
					</div>
					
					<div data-of-toggled-multiple="table" class="of-hidden">
					
						<div class="of-table-clones" style="display: none">
							<i>
								<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g><use xlink:href="{$imagePath}/icons.svg#arrow-down" /></g></svg>
							</i>
							<i>
								<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g><use xlink:href="{$imagePath}/icons.svg#arrow-up"></use></g>
								</svg>	
							</i>
						</div>
						
						<table class="of-table of-table-even-odd of-grid-table of-todo-list" data-of-sortable="">
							
							<thead>
								<tr>
									<th style="width: 45px;">
										<div style="width: 15px;"/>
									</th>
									<th data-of-default-sort=""><xsl:value-of select="$i18n.Task" /></th>
									<th><xsl:value-of select="$i18n.TaskList" /></th>
									<th><xsl:value-of select="$i18n.ResponsibleUser" /></th>
									<th><xsl:value-of select="$i18n.Status" /></th>
									<th><xsl:value-of select="$i18n.Deadline" /></th>
									<xsl:if test="/Document/hasManageAccess">
										<th style="width: 85px;">
											<div style="width: 45px;"/>
										</th>
									</xsl:if>
								</tr>
							</thead>
							
							<tbody id="shownTableRows" data-toggletaskalias="{/Document/requestinfo/currentURI}/{/Document/module/alias}/toggletask">
								<xsl:apply-templates select="ActiveTaskLists/TaskList" mode="table" />
							</tbody>
							
						</table>
						
						<table class="of-hidden">
							
							<tbody id="filteredTableRows"/>
							
							<tbody id="rowDetailsTemplate">
								<tr class="rowDetails">
									<td>
										<xsl:attribute name="colspan">
											<xsl:choose>
												<xsl:when test="/Document/hasManageAccess">7</xsl:when>
												<xsl:otherwise>6</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										
										<span class="margin">span</span>
										<ul class="of-meta-line">
											<li class="poster"></li>
											<li class="posted"></li>
											<li class="editor"></li>
											<li class="updated"></li>
										</ul>
									</td>
								</tr>
							</tbody>
							
						</table>
					
					</div>
					
				</xsl:when>
				<xsl:otherwise>
					<div class="of-inner-padded-b-half"><xsl:value-of select="$i18n.NoTaskLists" /></div>
				</xsl:otherwise>
			</xsl:choose>
		
			<xsl:if test="FinishedTaskLists/TaskList">
				
				<div id="finishedTaskListsFooter" class="bigmargintop">
				
					<xsl:value-of select="$i18n.FinishedTaskLists" /><xsl:text>:&#160;</xsl:text>
					
					<xsl:apply-templates select="FinishedTaskLists/TaskList" mode="finished-list" />
				
				</div>
				
			</xsl:if>
		
		</article>
		
		<xsl:if test="/Document/hasManageAccess">
			<xsl:call-template name="createModalDialogs">
				<xsl:with-param name="formURI">
					<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template name="createModalDialogs">
	
		<xsl:param name="formURI" />
		
		<div class="of-modal" data-of-modal="add-task">
			
			<a href="#" data-of-close-modal="add-task" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2><xsl:value-of select="$i18n.NewTask" /></h2>
			</header>

			<form data-action-orig="{$formURI}?method=addtask" method="post" class="of-form no-auto-scroll">

				<!-- <xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'taskListID'"/>
				</xsl:call-template> -->

				<div>
					
					<label class="of-block-label">
						<span><xsl:value-of select="$i18n.TaskList" /></span>
						<xsl:call-template name="createOFDropdown">
							<xsl:with-param name="name" select="'taskListID'"/>
							<xsl:with-param name="valueElementName" select="'taskListID'" />
							<xsl:with-param name="labelElementName" select="'name'" />
							<xsl:with-param name="element" select="TaskLists/TaskList"/>
							<xsl:with-param name="showInline" select="false()"/>
						</xsl:call-template>
					</label>
					
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
					<span class="of-btn-link">eller <a data-of-close-modal="add-task" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
		<div class="of-modal" data-of-modal="update-task">
			
			<a href="#" data-of-close-modal="update-task" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2 />
			</header>

			<form data-action-orig="{$formURI}?method=updatetask" method="post" class="of-form no-auto-scroll">

				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatetask'">		
					<div class="validationerrors of-hidden" data-of-open-modal="update-task">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'taskID'"/>
				</xsl:call-template>

				<div>
					
					<label class="of-block-label">
						<span><xsl:value-of select="$i18n.TaskList" /></span>
						<xsl:call-template name="createOFDropdown">
							<xsl:with-param name="name" select="'taskListID'"/>
							<xsl:with-param name="valueElementName" select="'taskListID'" />
							<xsl:with-param name="labelElementName" select="'name'" />
							<xsl:with-param name="element" select="TaskLists/TaskList"/>
							<xsl:with-param name="showInline" select="false()"/>
						</xsl:call-template>
					</label>
					
					<label data-of-required="" class="of-block-label">
						<span><xsl:value-of select="$i18n.Task" /></span>
						<xsl:call-template name="createTextField">
							<xsl:with-param name="name" select="'title'" />
						</xsl:call-template>
					</label>
					
					<label class="of-block-label">
						<span data-of-description="{$i18n.Optional}"><xsl:value-of select="$i18n.Description" /></span>
						<!-- <xsl:call-template name="createTextArea">
							<xsl:with-param name="name" select="'description'"/>
							<xsl:with-param name="rows" select="'3'"/>
						</xsl:call-template> -->
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
					<span class="of-btn-link">eller <a data-of-close-modal="update-task" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
		<div class="of-modal" data-of-modal="update-tasklist">
			
			<a href="#" data-of-close-modal="update-tasklist" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2 />
			</header>

			<form data-action-orig="{$formURI}?method=updatetasklist" method="post" class="of-form no-auto-scroll">

				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatetasklist'">		
					<div class="validationerrors of-hidden" data-of-open-modal="update-tasklist">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'taskListID'"/>
				</xsl:call-template>

				<div>
					<label data-of-required="" class="of-block-label">
						<span><xsl:value-of select="$i18n.TaskListName" /></span>
						<xsl:call-template name="createTextField">
							<xsl:with-param name="name" select="'name'" />
						</xsl:call-template>
					</label>
				</div>
	
				<footer class="of-text-right">
					<a href="#" class="submit-btn of-btn of-btn-inline of-btn-gronsta"><xsl:value-of select="$i18n.Save" /></a>
					<span class="of-btn-link">eller <a data-of-close-modal="update-tasklist" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
	</xsl:template>
	
	<xsl:template match="ShowTaskList">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			<div class="of-right">
				<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}" class="of-btn of-btn-outline of-btn-xs of-btn-inline of-icon of-icon-xs">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#arrow-left"/></svg></i>
					<span><xsl:value-of select="$i18n.Back" /></span>
				</a>
			</div>
			
			<h2><xsl:value-of select="/Document/module/name" /></h2>
			
		</header>
		
		<article class="of-inner-padded-rbl of-inner-padded-t-half" data-toggletaskalias="{/Document/requestinfo/currentURI}/{/Document/module/alias}/toggletask">
			<xsl:apply-templates select="TaskList">
				<xsl:with-param name="mode" select="'SHOW'" />
			</xsl:apply-templates>
		</article>
		
		<xsl:if test="hasUpdateAccess">
			<xsl:call-template name="createModalDialogs">
				<xsl:with-param name="formURI">
					<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/showtasklist/<xsl:value-of select="TaskList/taskListID" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="TaskList" mode="active-list">
		
		<xsl:apply-templates select=".">
			<xsl:with-param name="mode" select="'LIST'" />
		</xsl:apply-templates>
	
	</xsl:template>
	
	<xsl:template match="TaskList" mode="finished-list">
		
		<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/showtasklist/{taskListID}"><xsl:value-of select="name" /></a>
		
		<xsl:if test="position() != last()">
			<xsl:text>,&#160;</xsl:text>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="TaskList">
		
		<xsl:param name="mode" />
		
		<a name="tasklist{taskListID}" />
		
		<div data-tasklistid="{taskListID}" data-name="{name}">
		
			<header>
				<h3 class="no-padding-rl">
					<xsl:if test="/Document/hasManageAccess">
						<span class="of-todo-tools">
							<a data-of-open-modal="update-tasklist" href="#"><xsl:value-of select="$i18n.Update" /></a>
							<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/deletetasklist/{taskListID}" class="of-icon of-icon-only" onclick="return confirm('{$i18n.DeleteTaskListConfirm}: {name}?');">
								<i>
									<svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
										<use xlink:href="#trash"/>
									</svg>
								</i>
								<span><xsl:value-of select="$i18n.Delete" /></span>
							</a>
						</span>
					</xsl:if>
					<span><xsl:value-of select="name" /></span>
				</h3>
			</header>
		
			<div>
				
				<xsl:choose>
					<xsl:when test="tasks/Task">
						<ul class="of-todo-list">
							<xsl:if test="/Document/hasManageAccess"><xsl:attribute name="class">of-todo-list ui-sortable</xsl:attribute></xsl:if>
							<xsl:choose>
								<xsl:when test="../../WithFinished">
									<xsl:apply-templates select="tasks/Task" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="tasks/Task[not(finished)]" />
								</xsl:otherwise>
							</xsl:choose>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<ul class="of-todo-list of-no-sort"><li class="bigmargintop"><xsl:value-of select="$i18n.NoTasks" /></li></ul>
					</xsl:otherwise>				
				</xsl:choose>
				
				<xsl:if test="/Document/hasManageAccess">
					<a data-of-open-modal="add-task" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline of-icon">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#plus"/></svg></i>
						<span><xsl:value-of select="$i18n.NewTask" /></span>
					</a>
				</xsl:if>
				
				<br/>
				
				<xsl:choose>
					<xsl:when test="$mode = 'LIST' and not(../../WithFinished)">
						
						<xsl:variable name="finishedTasksCount" select="count(tasks/Task[finished])" />
				
						<xsl:choose>
							<xsl:when test="$finishedTasksCount > 0">
								<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/showtasklist/{taskListID}">
									<xsl:value-of select="$i18n.ShowFinished.Part1" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$finishedTasksCount" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.ShowFinished.Part2" />
								</a>
							</xsl:when>
							<xsl:otherwise><br/><br/><br/></xsl:otherwise>
						</xsl:choose>
				
					</xsl:when>
					<xsl:when test="$mode = 'SHOW'">
						
						<ul class="of-todo-list" data-completed="">
							<xsl:if test="/Document/hasManageAccess"><xsl:attribute name="class">of-todo-list ui-sortable</xsl:attribute></xsl:if>
							<xsl:apply-templates select="tasks/Task[finished]" />
						</ul>
						
					</xsl:when>
				</xsl:choose>
				
			</div>
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="TaskList" mode="table">
		
		<xsl:if test="tasks/Task">
			<xsl:apply-templates select="tasks/Task" mode="table"/>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="Task" mode="table">
	
		<xsl:if test="not(finished) or ../../../../WithFinished">
		
			<xsl:variable name="taskStates">
				<xsl:for-each select="TaskStates/TaskState"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each> 
			</xsl:variable>
			
			<xsl:variable name="posterPrinted">
				<xsl:call-template name="printUser">
					<xsl:with-param name="user" select="poster" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="editorPrinted">
				<xsl:call-template name="printUser">
					<xsl:with-param name="user" select="editor" />
				</xsl:call-template>
			</xsl:variable>
			
			<tr data-taskid="{taskID}" data-tasklistid="{../../taskListID}" data-title="{title}" data-name="{../../name}" data-description="{description}"
			 		data-responsibleuser="{responsibleUser/userID}" data-deadline="{substring(deadline,1,10)}"
			 		data-poster="{$posterPrinted}" data-posted="{posted}"	data-updated="{updated}" data-editor="{$editorPrinted}">
			 		
				<xsl:attribute name="class">
					
					<xsl:choose>
						<xsl:when test="TaskStates[TaskState = 'MISSEDDEADLINE']">of-status-poor </xsl:when>
						<xsl:otherwise>of-status-good </xsl:otherwise>
					</xsl:choose>
					
					<xsl:if test="responsibleUser">of-assigned </xsl:if>
					
					<xsl:if test="finished">completed </xsl:if>
					
					<xsl:value-of select="$taskStates" />
					
				</xsl:attribute>
				
				<td>
					<div class="of-checkbox-label">
						<label>
							<xsl:variable name="finished"><xsl:if test="finished"><xsl:value-of select="'true'" /></xsl:if></xsl:variable>
							<xsl:call-template name="createCheckbox">
								<xsl:with-param name="name" select="concat('task_', taskID)" />
								<xsl:with-param name="value" select="taskID" />
								<xsl:with-param name="checked" select="$finished" />
								<xsl:with-param name="disabled" select="not(/Document/hasManageAccess) or responsibleUser[userID != /Document/user/userID]" />
							</xsl:call-template>
							<em tabindex="0" class="of-checkbox">
								<xsl:attribute name="title">
									<xsl:choose>
										<xsl:when test="finished"><xsl:value-of select="$i18n.MarkAsNotFinished" /></xsl:when>
										<xsl:otherwise><xsl:value-of select="$i18n.MarkAsFinished" /></xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</em>
						</label>
					</div>
				</td>
				
				<td data-of-tr="{$i18n.Task}"><xsl:value-of select="title"/></td>
				
				<td data-of-tr="{$i18n.TaskList}"><xsl:value-of select="../../name"/></td>
				
				<td class="responsibleuser" data-of-tr="{$i18n.ResponsibleUser}">
							<xsl:choose>
								<xsl:when test="responsibleUser">
										<xsl:call-template name="printUser">
											<xsl:with-param name="user" select="responsibleUser" />
										</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$i18n.NotAssigned" />
								</xsl:otherwise>
							</xsl:choose>
				</td>
				
				<td data-of-tr="{$i18n.Status}" data-taskstatus="">
					<xsl:choose>
						<xsl:when test="finished">
							<xsl:value-of select="$i18n.Finished" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$i18n.Active" />
						</xsl:otherwise>
					</xsl:choose>
				</td>
				
				<td data-of-tr="{$i18n.Deadline}"><xsl:value-of select="substring(deadline,1,10)" /></td>
	
				<xsl:if test="/Document/hasManageAccess">
					<td>
							<xsl:variable name="sectionID" select="../../sectionID"/>
						
							<xsl:variable name="taskModuleAlias">
								<xsl:choose>
								<xsl:when test="../../../TaskModule[sectionID = $sectionID]">
									<xsl:value-of select="../../../TaskModule[sectionID = $sectionID]/fullAlias"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'/'"/>
									<xsl:value-of select="/Document/module/alias"/>
								</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="MyTasksRedirect">
								<xsl:choose>
								<xsl:when test="../../../TaskModule[sectionID = $sectionID]">
									<xsl:value-of select="'?redirectURI=/'"/>
									<xsl:value-of select="/Document/module/alias"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''"/>
								</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="MyTasksModal">
								<xsl:choose>
								<xsl:when test="../../../TaskModule[sectionID = $sectionID]">
									<xsl:value-of select="'-section-'"/>
									<xsl:value-of select="$sectionID"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''"/>
								</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<a class="floatleft" data-of-open-modal="update-task{$MyTasksModal}" data-modal-mode="update" href="#"><xsl:value-of select="$i18n.Update" /></a>
							
							<a class="floatleft marginleft of-icon of-icon-only" href="{/Document/requestinfo/currentURI}{$taskModuleAlias}/deletetask/{taskID}{$MyTasksRedirect}" onclick="return confirm('{$i18n.DeleteTaskConfirm}: {title}?');">
								<i>
									<svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
										<use xlink:href="#trash" />
									</svg>
								</i>
								<span><xsl:value-of select="$i18n.Delete" /></span>
							</a>
							
					</td>
				</xsl:if>
			
			</tr>
			
		</xsl:if>
	
	</xsl:template>
	
	<xsl:template match="TaskState">
		<xsl:value-of select="." />
	</xsl:template>
	
	<xsl:template match="Task">
	
		<xsl:variable name="taskStates">
			<xsl:for-each select="TaskStates/TaskState"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each> 
		</xsl:variable>
		
		<xsl:variable name="sectionID" select="../../sectionID"/>
		
		<xsl:variable name="MyTasksModal">
			<xsl:choose>
			<xsl:when test="../../../TaskModule[sectionID = $sectionID]">
				<xsl:value-of select="'-section-'"/>
				<xsl:value-of select="$sectionID"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''"/>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<li data-taskid="{taskID}" data-title="{title}" data-description="{description}" data-responsibleuser="{responsibleUser/userID}" data-deadline="{substring(deadline,1,10)}" class="of-status-good">
			
			<xsl:attribute name="class">

				<xsl:choose>
					<xsl:when test="TaskStates[TaskState = 'MISSEDDEADLINE']">of-status-poor </xsl:when>
					<xsl:otherwise>of-status-good </xsl:otherwise>
				</xsl:choose>
				
				<xsl:if test="responsibleUser">of-assigned </xsl:if>
				
				<xsl:if test="finished">completed </xsl:if>
				
				<xsl:value-of select="$taskStates" />
				
			</xsl:attribute>
			
			<a name="task{taskID}" />
			
			<xsl:if test="/Document/hasManageAccess">
				<span class="of-todo-tools">
				
					<xsl:variable name="taskModuleAlias">
						<xsl:choose>
						<xsl:when test="../../../TaskModule[sectionID = $sectionID]">
							<xsl:value-of select="../../../TaskModule[sectionID = $sectionID]/fullAlias"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'/'"/>
							<xsl:value-of select="/Document/module/alias"/>
						</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="MyTasksRedirect">
						<xsl:choose>
						<xsl:when test="../../../TaskModule[sectionID = $sectionID]">
							<xsl:value-of select="'?redirectURI=/'"/>
							<xsl:value-of select="/Document/module/alias"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="''"/>
						</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<a data-of-open-modal="update-task{$MyTasksModal}" data-modal-mode="update" href="#"><xsl:value-of select="$i18n.Update" /></a>
					<a href="{/Document/requestinfo/currentURI}{$taskModuleAlias}/deletetask/{taskID}{$MyTasksRedirect}" class="of-icon of-icon-only" onclick="return confirm('{$i18n.DeleteTaskConfirm}: {title}?');">
						<i>
							<svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
								<use xlink:href="#trash" />
							</svg>
						</i>
						<span><xsl:value-of select="$i18n.Delete" /></span>
					</a>
				</span>
			</xsl:if>
			
			<div class="of-checkbox-label">
				<label>
					<xsl:variable name="finished"><xsl:if test="finished"><xsl:value-of select="'true'" /></xsl:if></xsl:variable>
					<xsl:call-template name="createCheckbox">
						<xsl:with-param name="name" select="concat('task_', taskID)" />
						<xsl:with-param name="value" select="taskID" />
						<xsl:with-param name="checked" select="$finished" />
						<xsl:with-param name="disabled" select="not(/Document/hasManageAccess) or responsibleUser[userID != /Document/user/userID]" />
					</xsl:call-template>
					<em tabindex="0" class="of-checkbox">
						<xsl:attribute name="title">
							<xsl:choose>
								<xsl:when test="finished"><xsl:value-of select="$i18n.MarkAsNotFinished" /></xsl:when>
								<xsl:otherwise><xsl:value-of select="$i18n.MarkAsFinished" /></xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</em>
				</label>
				<span>
				
					<xsl:value-of select="title" />
					<xsl:if test="finished">
						<xsl:text>&#160;</xsl:text>
						<span class="completed-by">
							<i>(<xsl:value-of select="$i18n.FinishedBy" /><xsl:text>&#160;</xsl:text> 
								<xsl:call-template name="printUser">
									<xsl:with-param name="user" select="finishedByUser" />
								</xsl:call-template>
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="finished" />)
							</i>
						</span>
					</xsl:if>
				
				</span>
				
				<div data-of-open-modal="update-task{$MyTasksModal}" data-modal-mode="assign" class="of-tag">
					<ul class="of-meta-line">
						<xsl:choose>
							<xsl:when test="responsibleUser">
								<li class="responsibleuser">
									<xsl:call-template name="printUser">
										<xsl:with-param name="user" select="responsibleUser" />
									</xsl:call-template>
								</li>
								<xsl:if test="deadline">
									<li><xsl:value-of select="substring(deadline,1,10)" /></li>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise><li><xsl:value-of select="$i18n.NotAssigned" /></li></xsl:otherwise>
						</xsl:choose>
					</ul>
				</div>
				
			</div>
			
			<xsl:if test="description">
				<div class="of-todo-description">
					<xsl:call-template name="replaceLineBreaksAndLinks">
						<xsl:with-param name="string" select="description"/>
					</xsl:call-template>
				</div>
			</xsl:if>
			
			<ul class="of-meta-line">
				<li>
					<xsl:value-of select="$i18n.AddedBy" /><xsl:text>&#160;</xsl:text>
					<xsl:call-template name="printUser">
						<xsl:with-param name="user" select="poster" />
					</xsl:call-template>
				</li>
				<li>
					<xsl:value-of select="posted" />
				</li>
				<xsl:if test="updated">
					<li>
						<xsl:value-of select="$i18n.UpdatedBy" /><xsl:text>&#160;</xsl:text>
						<xsl:call-template name="printUser">
							<xsl:with-param name="user" select="editor" />
						</xsl:call-template>
					</li>
					<li>
						<xsl:value-of select="updated" />
					</li>
				</xsl:if>
			</ul>
		</li>
	
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
					<xsl:when test="messageKey='TaskListNotFound'">
						<span class="validationerror" data-parameter="{fieldName}">
							<span class="description error">
								<xsl:value-of select="$i18n.TaskListNotFound" />
							</span>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<p class="error"><xsl:value-of select="$i18n.validationError.unknownMessageKey" />!</p>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:if>
		<xsl:apply-templates select="message" />
		
	</xsl:template>
	
</xsl:stylesheet>