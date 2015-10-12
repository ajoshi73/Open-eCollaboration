<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template match="Task" mode="compact">
		
		<xsl:variable name="taskStates">
			<xsl:for-each select="TaskStates/TaskState"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each> 
		</xsl:variable>
	
		<xsl:variable name="moduleAlias">
			<xsl:choose>
				<xsl:when test="moduleAlias">
					<xsl:value-of select="moduleAlias" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/Document/tasksModuleAlias" />
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
	
		<li data-taskid="{taskID}" class="of-status-good" data-toggletaskalias="{$moduleAlias}/toggletask">
		
			<xsl:attribute name="class">

				<xsl:choose>
					<xsl:when test="TaskStates[TaskState = 'MISSEDDEADLINE']">of-status-poor </xsl:when>
					<xsl:otherwise>of-status-good </xsl:otherwise>
				</xsl:choose>
				
				<xsl:value-of select="$taskStates" />
				
			</xsl:attribute>
		
			<div class="of-checkbox-label">
				<label>
					<xsl:call-template name="createCheckbox">
						<xsl:with-param name="name" select="concat('task_', taskID)" />
						<xsl:with-param name="value" select="taskID" />
						<xsl:with-param name="disabled" select="responsibleUser[userID != /Document/user/userID]" />
					</xsl:call-template>
					<em tabindex="0" class="of-checkbox"></em>
				</label>
				
				<a href="{$moduleAlias}/showtasklist/{TaskList/taskListID}#task{taskID}">
					<span><xsl:value-of select="TaskList/name" /><xsl:text>:&#160;</xsl:text><xsl:value-of select="title" /></span>
				</a>
			</div>
			<ul class="of-meta-line">
				<xsl:if test="deadline">
					<li><xsl:value-of select="substring(deadline,1,10)" /></li>
				</xsl:if>
				<xsl:if test="responsibleUser">
					<li>
						<xsl:value-of select="$i18n.Responsible" /><xsl:text>:&#160;</xsl:text>
						<xsl:call-template name="printUser">
							<xsl:with-param name="user" select="responsibleUser" />
						</xsl:call-template>
					</li>
				</xsl:if>
				<xsl:if test="sectionName">
					<li><xsl:value-of select="sectionName" /></li>
				</xsl:if>
			</ul>
			
		</li>
		
	</xsl:template>
	
	<xsl:template name="printUser">
		
		<xsl:param name="user" />
		
		<xsl:choose>
			<xsl:when test="$user"><xsl:value-of select="$user/firstname" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$user/lastname" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$i18n.DeletedUser" /></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

</xsl:stylesheet>