<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<div id="ShortCutsBackgroundModule" class="contentitem of-module of-block">
		
			<xsl:if test="ShortCut">
				<footer class="of-block-footer-menu of-hide-to-sm">
					<ul>
						<xsl:apply-templates select="ShortCut" />
					</ul>
				</footer>
			</xsl:if>
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="ShortCut">
		
		<li>
			<a href="{/Document/ContextPath}{fullAlias}"><xsl:value-of select="name" /></a>
		</li>
		
	</xsl:template>
	
</xsl:stylesheet>