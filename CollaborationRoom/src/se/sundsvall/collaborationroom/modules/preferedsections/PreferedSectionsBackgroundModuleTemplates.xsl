<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/preferedsectionsbackgroundmodule.js
	</xsl:variable>

	<xsl:template match="Document">
		
		<script type="text/javascript">
			preferedSectionsConnector = '<xsl:value-of select="contextPath" /><xsl:value-of select="preferedSectionsConnector" />';
		</script>
		
		<xsl:apply-templates select="PreferedSections/section" />
	
		<xsl:if test="MemberSections/section and maxPreferedSections > count(PreferedSections/section)">
	
			<div id="PreferedSectionsModule" class="of-c-lg-4 of-c-xxl-third of-omega-lg">
	
				<div class="add-module of-hide-to-lg">
					<a data-of-open-modal="add-preferedsection" href="#" class="of-icon of-icon-md">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#plus"/></svg></i>
						<span><xsl:value-of select="$i18n.AddSection" /></span>
					</a>
				</div>
	
				<div class="of-modal" data-of-modal="add-preferedsection">
			
					<a href="#" data-of-close-modal="add-preferedsection" class="of-close of-icon of-icon-only">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
						<span><xsl:value-of select="$i18n.Close" /></span>
					</a>
		
					<header>
						<h2><xsl:value-of select="$i18n.AddSection" /></h2>
					</header>
		
					<div>
		
						<label class="of-block-label">
							<span><xsl:value-of select="$i18n.ChooseSection" /></span>
							<xsl:call-template name="createOFDropdown">
								<xsl:with-param name="id" select="'PreferedSection'"/>
								<xsl:with-param name="name" select="'sectionID'"/>
								<xsl:with-param name="valueElementName" select="'sectionID'" />
								<xsl:with-param name="labelElementName" select="'name'" />
								<xsl:with-param name="showInline" select="false()" />
								<xsl:with-param name="element" select="MemberSections/section"/>
							</xsl:call-template>
						</label>
						
					</div>
		
					<footer class="of-text-right">
						<a href="#" data-of-close-modal="add-preferedsection" class="of-btn of-btn-submit of-btn-inline of-btn-gronsta"><xsl:value-of select="$i18n.Add" /></a>
						<span class="of-btn-link"><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.or" /><xsl:text>&#160;</xsl:text><a data-of-close-modal="new-widget" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
					</footer>
					
				</div>
	
			</div>
		
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="section">
	
		<div class="of-omega-xs of-omega-sm of-c-md-2 of-c-lg-4 of-c-xxl-third of-hide-to-md">

			<div class="of-block">
				<header class="of-inner-padded-half">
					<span class="of-icon of-icon-xs">
						<a onclick="return confirm('{$i18n.DeleteConfirm}: {name}?');" class="of-icon of-right of-icon-only" href="{/Document/contextPath}{/Document/preferedSectionsConnector}/delete/{sectionID}" title="{$i18n.DeleteTitle}">
							<i>
								<svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
									<use xlink:href="#trash"/>
								</svg>
							</i>
							<span><xsl:value-of select="$i18n.Delete" /></span>
						</a>
					  </span>
					<h2 class="of-has-icon-right"><a href="{/Document/contextPath}{fullAlias}"><xsl:value-of select="name" /></a></h2>
					<ul class="of-meta-line">
						<li><xsl:value-of select="membersCount" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.members" /></li>
					</ul>
				</header>

				<article class="of-inner-padded-rbl-half">
					<ul class="of-feed-list">
						<xsl:choose>
							<xsl:when test="LatestEvents/ViewFragment">
								<xsl:apply-templates select="LatestEvents/ViewFragment" />
							</xsl:when>
							<xsl:otherwise>
								<li class="empty"><xsl:value-of select="$i18n.NoEvents" /></li>
							</xsl:otherwise>
						</xsl:choose>
					</ul>
				</article>

				<footer class="of-no-bg of-inner-padded-half">
					<ul class="of-meta-line">
					
						<xsl:variable name="accessMode" select="Attributes/Attribute[Name = 'accessMode']/Value"/>
						
						<xsl:if test="$accessMode = 'CLOSED' or $accessMode = 'HIDDEN'">
							<li class="of-right of-icon of-icon-only">
								<xsl:choose>
									<xsl:when test="$accessMode = 'CLOSED'">
										<xsl:attribute name="data-of-tooltip"><xsl:value-of select="$i18n.Closed" /></xsl:attribute>
										<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#lock"></use></svg></i>
										<span><xsl:value-of select="$i18n.Closed" /></span>
									</xsl:when>
									<xsl:when test="$accessMode = 'HIDDEN'">
										<xsl:attribute name="data-of-tooltip"><xsl:value-of select="$i18n.Hidden" /></xsl:attribute>
										<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#hidden"></use></svg></i>
										<span><xsl:value-of select="$i18n.Hidden" /></span>
									</xsl:when>
								</xsl:choose>
							</li>
						</xsl:if>
						
						<xsl:if test="eventCount > 0">
							<li><strong><xsl:value-of select="eventCount" /></strong><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.newEvents" /></li>
						</xsl:if>
					</ul>
				</footer>
			</div>
			
		</div>
	
	</xsl:template>
	
	<xsl:template match="ViewFragment">
		
		<xsl:value-of select="HTML" disable-output-escaping="yes"/>

	</xsl:template>
	
</xsl:stylesheet>