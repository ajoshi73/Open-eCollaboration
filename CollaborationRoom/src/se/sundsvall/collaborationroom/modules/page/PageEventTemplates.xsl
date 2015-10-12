<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'SMALL'">
				<xsl:apply-templates select="Page" mode="small"/>
			</xsl:when>
			<xsl:when test="Format = 'LARGE'">
				<xsl:apply-templates select="Page" mode="large"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:apply-templates select="Page" mode="email"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="Page" mode="email">
		
		<li>
			<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
				<xsl:call-template name="user">
					<xsl:with-param name="user" select="poster"/>
				</xsl:call-template>
			</a>
		
			<xsl:text>&#160;</xsl:text>
		
			<xsl:value-of select="$i18n.HasAddedPage"/>
		
			<xsl:text>&#160;</xsl:text>
		
			<a href="{../PageURL}"><xsl:value-of select="title"/></a>
		
			<xsl:text>&#160;(</xsl:text>
		
			<xsl:value-of select="posted" />
		
			<xsl:text>)</xsl:text>
		</li>

	</xsl:template>	
	
	<xsl:template match="Page" mode="small">
		
		<li>
			<h5>
				<xsl:value-of select="posted" />
				<xsl:text>:&#160;</xsl:text>
				<span>
					<xsl:call-template name="user">
						<xsl:with-param name="user" select="poster"/>
					</xsl:call-template>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n.HasAddedPage"/>
					<xsl:text>&#160;</xsl:text>
					<a href="{../PageURL}"><xsl:value-of select="title"/></a>
				</span>
			</h5>
		</li>

	</xsl:template>

	<xsl:template match="Page" mode="large">

		<li>
			<figure class="of-profile">
				<xsl:if test="poster and /Document/ProfileImageAlias">
					<img alt="{poster/firstname} {poster/lastname}" src="{/Document/ContextPath}{/Document/ProfileImageAlias}/{poster/userID}" />
				</xsl:if>
			</figure>
	
			<article>
				<header>
					<h3>
						<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
							<xsl:call-template name="user">
								<xsl:with-param name="user" select="poster"/>
							</xsl:call-template>
						</a>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$i18n.HasAddedPage"/>
						<xsl:text> </xsl:text>
						<a href="{../PageURL}"><xsl:value-of select="title"/></a>
					</h3>
				</header>
	
				<ul class="of-meta-line">
					<li class="of-icon">
						<i>
							<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
								<use xlink:href="#file"></use>
							</svg>
						</i>
						<xsl:value-of select="$i18n.Page"/>
					</li>
					<li><xsl:value-of select="posted"/></li>
				</ul>
			</article>
		</li>

	</xsl:template>
	
	<xsl:template name="user">
		
		<xsl:param name="user"/>
		
		<xsl:choose>
			<xsl:when test="$user">
				<xsl:value-of select="$user/firstname"/>
				<xsl:text>&#x20;</xsl:text>
				<xsl:value-of select="$user/lastname"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$i18n.DeletedUser"/>
			</xsl:otherwise>
		</xsl:choose> 	
	</xsl:template>	
	
</xsl:stylesheet>