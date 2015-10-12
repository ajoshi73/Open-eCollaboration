<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/linkarchivebackgroundmodule.js
	</xsl:variable>

	<xsl:template match="Document">
		
		<div class="contentitem of-module">
			
			<script type="text/javascript">
				linkArchiveModuleAlias = '<xsl:value-of select="contextPath" /><xsl:value-of select="linkArchiveModuleAlias" />';
			</script>
			
			<xsl:apply-templates select="ListLinks" />
			
		</div>
		
	</xsl:template>

	<xsl:template match="ListLinks">
		
		<section class="of-rss-feed of-block">

			<header>
				<h3><xsl:value-of select="/Document/moduleName" /></h3>
				<a href="{/Document/contextPath}{/Document/linkArchiveModuleAlias}" title="{$i18n.Settings}" class="of-icon of-icon-only of-absolute-right of-hover-touch-show">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#cog"/></svg></i>
					<span><xsl:value-of select="$i18n.Settings" /></span>
				</a>
			</header>
		
			<article class="of-inner-padded-half">
				<ul class="of-feed-list of-link-list of-no-bullets">
					<xsl:choose>
						<xsl:when test="Links/Link">
							<xsl:apply-templates select="Links/Link" mode="compact" />
						</xsl:when>
						<xsl:otherwise>
							<li class="empty"><xsl:value-of select="$i18n.NoLinks" /></li>
						</xsl:otherwise>
					</xsl:choose>				
				</ul>
			</article>

			<xsl:if test="Links/Link">
				<footer>
					<a id="showMoreLinksLink" href="#" class="of-block-link">
						<span><xsl:value-of select="$i18n.ShowMore" /></span>
					</a>
				</footer>
			</xsl:if>
		
		</section>
	
	</xsl:template>
	
	<xsl:template match="Link" mode="compact">
		
		<li data-linkid="{linkID}">
			<a href="{url}" class="of-icon of-icon-xs of-icon-absolute-right" target="_blank">
				<h5><xsl:value-of select="name" /></h5>
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#external"/></svg></i>
			</a>
		</li>
		
	</xsl:template>
	
</xsl:stylesheet>