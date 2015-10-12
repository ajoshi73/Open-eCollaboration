<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="LoadAdditionalPosts">
				<xsl:apply-templates select="LoadAdditionalPosts" />
			</xsl:when>
			<xsl:otherwise>
				
				<div class="contentitem of-module of-dialog-block floatleft full">
			
					<xsl:apply-templates select="LatestPosts" />
					
					<script type="text/javascript">
						blogModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
					</script>
					
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="LatestPosts">
		
		<header class="of-inner-padded-trl of-hide-to-md of-clear">
			<h3><xsl:value-of select="$i18n.LatestPosts" /></h3>
		</header>
	
		<ul class="of-post-list of-inner-padded-rl">
		
			<script type="text/javascript">
				i18nBlogModule = {
					"READ_MORE": '<xsl:value-of select="$i18n.ReadMore" />',
					"HIDE_TEXT": '<xsl:value-of select="$i18n.HideText" />',
				};
			</script>

			<xsl:choose>
				<xsl:when test="Posts/Post">
					<xsl:apply-templates select="Posts/Post" mode="latestlist" />
				</xsl:when>
				<xsl:otherwise>
					<li class="empty"><xsl:value-of select="$i18n.NoPosts" /></li>
				</xsl:otherwise>
			</xsl:choose>
			
		</ul>
	
		<xsl:if test="Posts/Post">
			<footer>
				<a id="showMoreLink" href="#" class="of-block-link">
					<span><xsl:value-of select="$i18n.ShowMore" /></span>
				</a>
			</footer>
		</xsl:if>
	
	</xsl:template>
	
	<xsl:template match="LoadAdditionalPosts">
		
		<xsl:apply-templates select="Posts/Post" mode="latestlist" />
		
	</xsl:template>
	
	<xsl:template match="Post" mode="latestlist">
		
		<xsl:variable name="sectionID" select="sectionID" />
		
		<xsl:variable name="blogModule" select="../../BlogModules/BlogModule[sectionID = $sectionID]" />
		
		<xsl:apply-templates select="." mode="list">
			<xsl:with-param name="moduleAlias">
				<xsl:value-of select="/Document/requestinfo/contextpath" /><xsl:value-of select="$blogModule/fullAlias" />
			</xsl:with-param>
			<xsl:with-param name="sectionName"><xsl:value-of select="$blogModule/sectionName" /></xsl:with-param>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<xsl:template match="File" mode="show">
		
		<li class="of-icon file small">
			<div>
				<img src="{/Document/requestinfo/contextpath}{../../FileArchiveModuleAlias}/fileicon/{filename}" /><xsl:text>&#160;</xsl:text>
				<a href="{/Document/requestinfo/contextpath}{../../FileArchiveModuleAlias}/downloadfile/{fileID}"><xsl:value-of select="filename" /></a>
				<ul class="of-meta-line">
					<li><xsl:value-of select="FormattedSize" /></li>
					<li><xsl:value-of select="Category/name" /></li>
				</ul>
			</div>
		</li>
			
	</xsl:template>
	
	<xsl:template match="File" mode="image">
		
		<img src="{/Document/requestinfo/contextpath}{../../FileArchiveModuleAlias}/showimage/{fileID}" alt="{filename}" />
		
	</xsl:template>
	
</xsl:stylesheet>