<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/mysectionsbackgroundmodule.js
	</xsl:variable>

	<xsl:template match="Document">
		
		<div id="MySectionsBackgroundModule" class="samarbetsrum-header-section samarbetsrum-room">
	
			<div class="of-relative of-hide-from-md">
				<select name="samarbetsrum-select">
					<option data-href="#" value=""><xsl:value-of select="$i18n.ChooseSection" /></option>
					<xsl:if test="FavouriteSection">
						<optgroup label="{$i18n.Favourites}">
							<xsl:apply-templates select="FavouriteSection" />
						</optgroup>
					</xsl:if>
					<xsl:if test="MemberSection">
						<optgroup label="{$i18n.MySections}">
							<xsl:apply-templates select="MemberSection" />
						</optgroup>
					</xsl:if>
					<xsl:if test="mySectionsModuleAlias">
						<optgroup label="{$i18n.OpenSections}">
							<option data-href="{contextPath}{mySectionsModuleAlias}#sections"><xsl:value-of select="$i18n.ShowOpenSections" /></option>
						</optgroup>
					</xsl:if>
				</select>
				<a class="of-icon of-icon-lg" href="index.html">
					<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#list"></use></svg></i>
					<span><xsl:value-of select="$i18n.ChooseSection" /></span>
				</a>
			</div>

			<div class="of-select of-hide-to-md">			
				<select name="samarbetsrum-select" data-of-select="">
					<option data-href="#" value=""><xsl:value-of select="$i18n.ChooseSection" /></option>
					<xsl:if test="FavouriteSection">
						<optgroup label="{$i18n.Favourites}">
							<xsl:apply-templates select="FavouriteSection" />
						</optgroup>
					</xsl:if>
					<xsl:if test="MemberSection">
						<optgroup label="{$i18n.MySections}">
							<xsl:apply-templates select="MemberSection" />
						</optgroup>
					</xsl:if>
					<xsl:if test="mySectionsModuleAlias">
						<optgroup label="{$i18n.OpenSections}">
							<option data-href="{contextPath}{mySectionsModuleAlias}#sections"><xsl:value-of select="$i18n.ShowOpenSections" /></option>
						</optgroup>
					</xsl:if>
				</select>
			</div>
			
		</div>
		
	</xsl:template>
	
	<xsl:template match="FavouriteSection">
	
		<option data-href="{/Document/contextPath}{fullAlias}" value="{sectionID}"><xsl:value-of select="name" /></option>
	
	</xsl:template>
	
	<xsl:template match="MemberSection">
		
		<option data-href="{/Document/contextPath}{fullAlias}" value="{sectionID}"><xsl:value-of select="name" /></option>
		
	</xsl:template>
	
</xsl:stylesheet>