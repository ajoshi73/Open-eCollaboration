<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/latestevents.js
	</xsl:variable>

	<xsl:template match="Document">
		
		<div class="of-dialog-block">
			<header class="of-inner-padded-trl">
				<h3><xsl:value-of select="$i18n.title"/></h3>
			</header>
		
			<xsl:choose>
				<xsl:when test="Events">
				
					<ul class="of-activity-list of-inner-padded-rl">
				
						<xsl:apply-templates select="Events/ViewFragment"/>
				
					</ul>
				
					<xsl:if test="ConnectorURL">
					
						<script>
							latestEventsConnector = '<xsl:value-of select="ConnectorURL"/>';
						</script>
					
						<footer>
							<a class="of-block-link" href="#" id="showMoreEventsLink">
								<span><xsl:value-of select="$i18n.ShowMoreEvents"/></span>
							</a>
						</footer>					
					</xsl:if>
				
				</xsl:when>
				<xsl:otherwise>
		
					<ul class="of-activity-list of-inner-padded-rl">
						<li><xsl:value-of select="$i18n.NoEventsFound"/></li>
					</ul>
				
				</xsl:otherwise>
			</xsl:choose>
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="ViewFragment">
		
		<xsl:value-of select="HTML" disable-output-escaping="yes"/>

	</xsl:template>
	
</xsl:stylesheet>