<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="staticContent"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" /></xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
	</xsl:variable>

	<xsl:template match="Document">
	
		<div id="SectionOverviewModule" class="contentitem of-module">
		
			<xsl:apply-templates select="SectionOverview" />
			<xsl:apply-templates select="DeleteWarning" />
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="SectionOverview">
		
		<div class=" of-no-margin">
			
			<header class="of-inner-padded-trl">
				<h1 class="of-clear"><xsl:value-of select="$i18n.SectionOverview" /></h1>
			</header>
			
			<div class="of-inner-padded-trl">
				<xsl:value-of select="$i18n.SectionCountPre" />
				<xsl:value-of select="SectionCount" />
				<xsl:value-of select="$i18n.SectionCountPost" />
				
				<xsl:value-of select="$i18n.TotalFilestorePre" />
				<xsl:value-of select="TotalFilestoreUsage" />
				<xsl:value-of select="$i18n.TotalFilestorePost" />
			</div>
			
			<div class="of-inner-padded of-block">
			
				<div class="of-table-clones" style="display: none">
					<i>
						<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g><use xlink:href="{$staticContent}/pics/icons.svg#arrow-down" /></g></svg>
					</i>
					<i>
						<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g><use xlink:href="{$staticContent}/pics/icons.svg#arrow-up"></use></g>
						</svg>	
					</i>
				</div>
				
				<table class="of-table of-table-even-odd of-grid-table" data-of-sortable="">
					<thead>
						<tr>
						
							<th data-of-default-sort=""><xsl:value-of select="$i18n.Name" /></th>
							<th><xsl:value-of select="$i18n.MemberCount" /></th>
							<th><xsl:value-of select="$i18n.Privacy" /></th>
							<th class="sorter-metadata"><xsl:value-of select="$i18n.Storage" /></th>
							<th><xsl:value-of select="$i18n.SectionType" /></th>
<!-- 							<th><xsl:value-of select="$i18n.Archived" /></th> -->
							<th style="width: 170px;">
								<div style="width: 135px;">
									<xsl:value-of select="$i18n.Deleted" />
								</div>
							</th>
							
						</tr>
					</thead>
					<tbody>
						<xsl:choose>
							<xsl:when test="Sections/section">
							
								<xsl:apply-templates select="Sections/section"/>
								
							</xsl:when>
							<xsl:otherwise>
							
								<tr>
									<td colspan="7"><xsl:value-of select="$i18n.NoSections" /></td>
								</tr>
								
							</xsl:otherwise>
						</xsl:choose>
					</tbody>
				</table>
			
			</div>

		</div>
		
	</xsl:template>

	<xsl:template match="section">
	
		<xsl:variable name="accessMode" select="Attributes/Attribute[Name = 'accessMode']/Value"/>
	
		<tr>
			
			<td data-of-tr="{$i18n.Name}">
				<a class="of-dark-link" href="{/Document/requestinfo/contextpath}{fullAlias}">
					
					<figure class="of-badge-vattjom of-room of-figure-xs">
						<xsl:if test="/Document/CBUtilityModuleAlias">
							<img src="{/Document/requestinfo/contextpath}{/Document/CBUtilityModuleAlias}/sectionlogo/{sectionID}" alt="{name}" />
						</xsl:if>
					</figure>
			
					<article>
						<header>
							<h2><xsl:value-of select="name" /></h2>
						</header>
					</article>
					
				</a>
			</td>
			
			<td data-of-tr="{$i18n.MemberCount}">
				<xsl:value-of select="MemberCount" />
			</td>
			
			<xsl:choose>
				<xsl:when test="$accessMode = 'CLOSED' or $accessMode = 'HIDDEN'">
					<td data-of-tr="{$i18n.Privacy}" class="of-icon">
						<xsl:choose>
							<xsl:when test="$accessMode = 'CLOSED'">
								<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#lock"></use></svg></i>
								<span><xsl:value-of select="$i18n.Closed" /></span>
							</xsl:when>
							<xsl:when test="$accessMode = 'HIDDEN'">
								<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#hidden"></use></svg></i>
								<span><xsl:value-of select="$i18n.Hidden" /></span>
							</xsl:when>
						</xsl:choose>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td></td>
				</xsl:otherwise>
			</xsl:choose>
			
			<td data-of-tr="{$i18n.Storage}" data-sortvalue="{FilestoreUsageBytes}">
					<span><xsl:value-of select="FilestoreUsage" /></span>
			</td>
			
			<td data-of-tr="{$i18n.SectionType}">
				<span><xsl:value-of select="SectionType/name" /></span>
			</td>
			
<!-- 			<td data-of-tr="{$i18n.Archived}"> -->
<!-- 				<xsl:if test="Attributes/Attribute[Name = 'archived']"> -->
				
<!-- 					<xsl:attribute name="class"> -->
<!-- 						<xsl:value-of select="'of-icon'"/> -->
<!-- 					</xsl:attribute> -->
					
<!-- 					<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#chain"></use></svg></i> -->
<!-- 					<span><xsl:value-of select="$i18n.Archived" /></span> -->
					
<!-- 				</xsl:if> -->
<!-- 			</td> -->
			
			<td data-of-tr="{$i18n.Deleted}">
				<xsl:choose>
				<xsl:when test="Attributes/Attribute[Name = 'deleted']">
				
					<a class="of-btn of-btn-vattjom of-btn-xs of-btn-inline of-icon" href="{/Document/requestinfo/contextpath}{/Document/section/fullAlias}/{/Document/module/alias}/restore/{sectionID}" onclick="return confirm('{$i18n.RestoreTaskConfirm}: {name}?');">
						<span>
							<xsl:value-of select="$i18n.RestoreSection"/>
							
							<xsl:if test="DaysRemaining">
								<xsl:text>,&#160;</xsl:text>
								<xsl:value-of select="DaysRemaining"/>
								<xsl:value-of select="$i18n.RestoreSectionPost"/>
							</xsl:if>
							
						</span>
					</a>
				
				</xsl:when>
				<xsl:otherwise>
				
					<a class="of-btn of-btn-rodon of-btn-xs of-btn-inline of-icon" href="{/Document/requestinfo/contextpath}{/Document/section/fullAlias}/{/Document/module/alias}/warning/{sectionID}">
						<i>
							<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
								<use xlink:href="#trash"/>
							</svg>
						</i>
						<span><xsl:value-of select="$i18n.DeleteSection"/></span>
					</a>
				
				</xsl:otherwise>
				</xsl:choose>
			</td>
			
		</tr>
	
	</xsl:template>
	
	<xsl:template match="DeleteWarning">

		<div class="of-inner-padded">

			<xsl:value-of select="Message" disable-output-escaping="yes"/>

		</div>

		<footer class="of-text-right of-inner-padded of-no-bg">
			
			<a class="of-btn of-btn-rodon of-btn-inline" href="{/Document/requestinfo/contextpath}{FullAlias}/delete/{SectionID}">
				<span>
					<xsl:value-of select="$i18n.DeleteSection"/>
				</span>
			</a>					
			
			<span class="of-btn-link">
				<xsl:value-of select="$i18n.or"/>
				<xsl:text>&#160;</xsl:text>
				<a href="{/Document/requestinfo/contextpath}/{section/alias}">
					<xsl:value-of select="$i18n.Cancel"/>
				</a></span>
		</footer>

	</xsl:template>
	
</xsl:stylesheet>