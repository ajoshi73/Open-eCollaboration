<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<div class="contentitem of-module">
	
			<section class="of-block">
				<header>
					<h3><xsl:value-of select="moduleName" /></h3>
				</header>
				<div class="of-inner-padded-trl-half">
					<ul class="of-grid-list of-widget">
						<xsl:choose>
							<xsl:when test="section">
								<xsl:apply-templates select="section" />
							</xsl:when>
							<xsl:otherwise>
								<li class="empty"><xsl:value-of select="$i18n.NoFavourites" /></li>
							</xsl:otherwise>
						</xsl:choose>
					</ul>
				</div>
			</section>
			
		</div>
		
	</xsl:template>
	
	<xsl:template match="section">
	
		<xsl:variable name="accessMode" select="Attributes/Attribute[Name = 'accessMode']/Value"/>
	
		<li>
		
			<div class="of-icon of-icon-only of-absolute-right of-favourite favourited">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#star"/></svg></i>
			</div>
			<a href="{/Document/contextPath}{fullAlias}" class="of-dark-link">
				<figure class="of-badge-vattjom of-room of-figure-lg">
					<xsl:if test="/Document/CBUtilityModuleAlias">
						<img src="{/Document/contextPath}{/Document/CBUtilityModuleAlias}/sectionlogo/{sectionID}" alt="{name}" />
					</xsl:if>
				</figure>
				<article>
					<header>
						<h2><xsl:value-of select="name" /></h2>
					</header>
					<ul class="of-meta-line">
						<xsl:choose>
							<xsl:when test="$accessMode = 'CLOSED'">
								<li class="of-icon">
									<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#lock"></use></svg></i>
									<span>Slutet</span>
								</li>
							</xsl:when>
							<xsl:when test="$accessMode = 'HIDDEN'">
								<li class="of-icon">
									<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#hidden"></use></svg></i>
									<span>Dolt</span>
								</li>
							</xsl:when>
						</xsl:choose>
						<li><xsl:value-of select="membersCount" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.members" /></li>
					</ul>
				</article>
			</a>
		
		</li>
	
	</xsl:template>
	
</xsl:stylesheet>