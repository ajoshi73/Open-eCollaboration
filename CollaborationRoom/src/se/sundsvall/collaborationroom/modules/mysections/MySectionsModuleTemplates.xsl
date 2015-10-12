<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:variable name="staticContent"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" /></xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/mysectionsmodule.js
		/js/jquery.expander.min.js
	</xsl:variable>

	<xsl:template match="Document">
	
		<xsl:choose>
			<xsl:when test="LoadAdditionalSections">
				<xsl:apply-templates select="LoadAdditionalSections" />
			</xsl:when>
			<xsl:otherwise>
			
				<div id="MySectionsModule" class="contentitem of-module">
					
					<a name="sections" />
	
					<xsl:apply-templates select="ListSections" />
		
					<script type="text/javascript">
						mySectionsModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
					</script>
		
				</div>
			
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="LoadAdditionalSections">
		
		<xsl:if test="MySections/section or OtherSections/section">
			
			<div class="list-items">
				<table>
					<tbody>
						<xsl:apply-templates select="MySections/section" mode="list">
							<xsl:with-param name="isUserSection" select="'true'" />
						</xsl:apply-templates>
						<xsl:apply-templates select="OtherSections/section" mode="list" />
					</tbody>
				</table>
			</div>
			<div class="grid-items">
				<xsl:apply-templates select="MySections/section" mode="grid">
					<xsl:with-param name="isUserSection" select="'true'" />
				</xsl:apply-templates>
				<xsl:apply-templates select="OtherSections/section" mode="grid" />
			</div>
			
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="ListSections">
		
		<div class=" of-no-margin">

			<header class="of-inner-padded-trl">
				<div class="of-right">
				
					<select id="room-filter-select" data-of-select="" class="room-filter-select of-inline-block" title="{$i18n.FilterTitle}">
						<xsl:if test="OtherSections"><option value="OPEN"><xsl:value-of select="$i18n.Open" /></option></xsl:if>
						<option value="MY"><xsl:value-of select="$i18n.My" /></option>
						<!-- <option value="ARCHIVED"><xsl:value-of select="$i18n.Archived" /></option> -->
					</select>

					<div id="view-toggler" class="of-inline-block of-btn-group">
						<a class="of-btn of-icon of-icon-only of-active" href="#" data-of-toggler-multiple="grid" title="{$i18n.GridTitle}">
							<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#grid"></use></svg></i>
							<span><xsl:value-of select="$i18n.Grid" /></span>
						</a>
						<a class="of-btn of-icon of-icon-only" href="#" data-of-toggler-multiple="list" title="{$i18n.ListTitle}">
							<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#list"></use></svg></i>
							<span><xsl:value-of select="$i18n.List" /></span>
						</a>
					</div>
				</div>
				
				<h3 class="of-clear"><xsl:value-of select="$i18n.Sections" /></h3>

			</header>
			
			<div class="of-inner-padded" data-of-toggled-multiple="grid">
			
				<ul class="of-grid-list">
					<xsl:apply-templates select="MySections/section" mode="grid">
						<xsl:with-param name="isUserSection" select="'true'" />
					</xsl:apply-templates>
					<xsl:apply-templates select="OtherSections/section" mode="grid" />
				</ul>
				
				<div id="no-sections-template" class=" of-hidden"><xsl:value-of select="$i18n.NoSections" /></div>
				
			</div>

			<div class="of-inner-padded of-hidden" data-of-toggled-multiple="list">
				
				<div class="of-table-clones" style="display: none">
					<i>
						<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g><use xlink:href="{$staticContent}/pics/icons.svg#arrow-down" /></g></svg>
					</i>
					<i>
						<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g><use xlink:href="{$staticContent}/pics/icons.svg#arrow-up"></use></g>
						</svg>	
					</i>
				</div>
				<table id="MySectionsTable" class="of-table of-table-even-odd of-grid-table" data-of-sortable="">
					<thead>
						<tr>
							<th data-of-default-sort=""><xsl:value-of select="$i18n.Name" /></th>
							<th><xsl:value-of select="$i18n.Members" /></th>
							<th><xsl:value-of select="$i18n.Privacy" /></th>
						</tr>
					</thead>
					<tbody>
						<xsl:choose>
							<xsl:when test="MySections/section">
								<xsl:apply-templates select="MySections/section" mode="list">
									<xsl:with-param name="isUserSection" select="'true'" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<tr><td colspan="3"><xsl:value-of select="$i18n.NoSections" /></td></tr>
							</xsl:otherwise>
						</xsl:choose>
					</tbody>
				</table>
				<table id="OtherSectionsTable" class="of-table of-table-even-odd of-grid-table" data-of-sortable="">
					<thead>
						<tr>
							<th data-of-default-sort=""><xsl:value-of select="$i18n.Name" /></th>
							<th><xsl:value-of select="$i18n.Members" /></th>
						</tr>
					</thead>
					<tbody>
						<xsl:choose>
							<xsl:when test="OtherSections/section">
								<xsl:apply-templates select="OtherSections/section" mode="list" />
							</xsl:when>
							<xsl:otherwise>
								<tr><td colspan="3"><xsl:value-of select="$i18n.NoSections" /></td></tr>
							</xsl:otherwise>
						</xsl:choose>
					</tbody>
				</table>
			</div>

			<footer>
				<a id="show-more-sections" class="of-block-link" href="#">
					<span><xsl:value-of select="$i18n.ShowMore" /></span>
				</a>
			</footer>

		</div>
		
	</xsl:template>
	
	<xsl:template match="section" mode="grid">
	
		<xsl:param name="isUserSection" select="'false'" />
		
		<xsl:variable name="accessMode" select="Attributes/Attribute[Name = 'accessMode']/Value"/>
		
		<xsl:variable name="mode">
			<xsl:choose>
				<xsl:when test="$isUserSection = 'true'">MY</xsl:when>
				<xsl:when test="Attributes/Attribute[Name = 'archived' and Value = 'true']">ARCHIVED</xsl:when>
				<xsl:when test="$accessMode = 'OPEN'">OPEN</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<li data-mode="{$mode}">
			<a class="of-dark-link" href="{/Document/requestinfo/contextpath}{fullAlias}">
				<figure class="of-badge-vattjom of-room of-figure-lg">
					<xsl:if test="/Document/CBUtilityModuleAlias">
						<img src="{/Document/requestinfo/contextpath}{/Document/CBUtilityModuleAlias}/sectionlogo/{sectionID}" alt="{name}" />
					</xsl:if>
				</figure>
				<article>
					<header>
						<h2><xsl:value-of select="name" /></h2>
					</header>
					<!-- <p>Uppdaterad för 2 timmar sedan.</p> -->
					<ul class="of-meta-line">
						<xsl:if test="$accessMode = 'CLOSED' or $accessMode = 'HIDDEN'">
							<li class="of-icon">
								<xsl:choose>
									<xsl:when test="$accessMode = 'CLOSED'">
										<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#lock"></use></svg></i>
										<span>Slutet</span>
									</xsl:when>
									<xsl:when test="$accessMode = 'HIDDEN'">
										<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#hidden"></use></svg></i>
										<span>Dolt</span>
									</xsl:when>
								</xsl:choose>
							</li>
						</xsl:if>
						<li><xsl:value-of select="membersCount" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.members" /></li>
					</ul>
				</article>
			</a>
		</li>
	
	</xsl:template>
	
	<xsl:template match="section" mode="list">
	
		<xsl:param name="isUserSection" select="'false'" />
		
		<xsl:variable name="accessMode" select="Attributes/Attribute[Name = 'accessMode']/Value"/>
	
		<xsl:variable name="mode">
			<xsl:choose>
				<xsl:when test="$isUserSection = 'true'">MY</xsl:when>
				<xsl:when test="Attributes/Attribute[Name = 'archived' and Value = 'true']">ARCHIVED</xsl:when>
				<xsl:when test="$accessMode = 'OPEN'">OPEN</xsl:when>
			</xsl:choose>
		</xsl:variable>
	
		<tr data-mode="{$mode}">
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
			<td data-of-tr="{$i18n.Members}"><xsl:value-of select="membersCount" /></td>
			<xsl:if test="$isUserSection = 'true'">
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
			</xsl:if>
		</tr>
	
	</xsl:template>
	
</xsl:stylesheet>