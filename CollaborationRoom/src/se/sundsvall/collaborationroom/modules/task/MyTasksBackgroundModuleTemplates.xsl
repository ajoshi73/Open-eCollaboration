<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/taskbackgroundmodule.js
	</xsl:variable>

	<xsl:template match="Document">
		
		<div class="contentitem of-module">
			
			<script type="text/javascript">
				tasksModuleAlias = '<xsl:value-of select="tasksModuleAlias" />';
				i18nTaskModule = {
					"FINISHED_BY": '<xsl:value-of select="$i18n.FinishedBy" />',
					"FINISHED_TITLE": '<xsl:value-of select="$i18n.MarkAsFinished" />',
					"NOT_FINISHED_TITLE": '<xsl:value-of select="$i18n.MarkAsNotFinished" />'
				};
			</script>
			
			<xsl:apply-templates select="ListTasks" />
			
		</div>
		
	</xsl:template>

	<xsl:template match="ListTasks">
		
		<section class="of-block">
			<header>
				<h3><xsl:value-of select="/Document/moduleName" /></h3>
			</header>
			<div class="of-inner-padded-rl-half">
				<ul class="of-todo-list of-widget" data-toggletaskalias="{/Document/tasksModuleAlias}/toggletask">
					<xsl:choose>
						<xsl:when test="Task"><xsl:apply-templates select="Task" mode="compact" /></xsl:when>
						<xsl:otherwise>
							<li class="of-inner-padded-trb-half"><xsl:value-of select="$i18n.NoTasks" /></li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
			<xsl:if test="Task">
				<footer>
					<a id="showMoreTasksLink" href="#" class="of-block-link">
						<span><xsl:value-of select="$i18n.ShowMore" /></span>
					</a>
				</footer>
			</xsl:if>
		</section>
	
	</xsl:template>
	
</xsl:stylesheet>