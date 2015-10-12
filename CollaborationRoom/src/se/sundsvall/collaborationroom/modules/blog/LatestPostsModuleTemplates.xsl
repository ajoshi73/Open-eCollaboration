<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

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
					<xsl:apply-templates select="Posts/Post" mode="list" />
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
	
</xsl:stylesheet>