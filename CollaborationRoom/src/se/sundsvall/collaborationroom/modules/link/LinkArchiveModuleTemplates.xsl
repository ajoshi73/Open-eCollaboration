<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/utils/js/common.js
		/js/linkarchivemodule.js
	</xsl:variable>

	<xsl:variable name="links">
		/css/linkarchivemodule.css
	</xsl:variable>

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="LoadAdditionalLinks">
			
				<xsl:apply-templates select="LoadAdditionalLinks" />
				
			</xsl:when>
			<xsl:otherwise>
				
				<div id="LinkArchiveModule" class="contentitem of-module of-block">
			
					<xsl:apply-templates select="ListLinks" />
					
					<script type="text/javascript">
						linkArchiveModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
					</script>
					
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="LoadAdditionalLinks">
		
		<xsl:apply-templates select="Links/Link" mode="compact" />
		
	</xsl:template>
	
	<xsl:template match="ListLinks">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			
			<xsl:if test="/Document/hasManageAccess">
				<div class="of-right">
					<a data-of-toggler="addlink" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline">
						<span><xsl:value-of select="$i18n.NewLink" /></span>
					</a>
				</div>
			</xsl:if>
			
			<h2><xsl:value-of select="/Document/module/name" /></h2>
		
		</header>
		
		<div class="of-border-bottom of-inner-padded of-hidden" data-of-toggled="addlink">
			
			<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=add" method="post" class="of-form">
				
				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'add'">		
					<div class="validationerrors of-hidden">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>
				
				<label data-of-required="" class="of-block-label">
					<span><xsl:value-of select="$i18n.LinkName" /></span>
					<xsl:call-template name="createTextField">
						<xsl:with-param name="name" select="'name'" />
					</xsl:call-template>
				</label>
				
				<label data-of-required="" class="of-block-label">
					<span><xsl:value-of select="$i18n.URL" /></span>
					<xsl:call-template name="createTextField">
						<xsl:with-param name="name" select="'url'" />
					</xsl:call-template>
				</label>
	
				<div class="of-text-right of-inner-padded-t-half">
					<button class="submit-btn of-btn of-btn-inline of-btn-gronsta" type="button"><xsl:value-of select="$i18n.Add" /></button>
				</div>
			</form>
			
		</div>
		
		<article class="of-inner-padded-rbl of-inner-padded-t-half">
			<xsl:choose>
				<xsl:when test="Link">
					<ul class="of-todo-list">
						<xsl:apply-templates select="Link" mode="list" />
					</ul>
				</xsl:when>
				<xsl:otherwise>
					<div class="of-inner-padded-b-half"><xsl:value-of select="$i18n.NoLinks" /></div>
				</xsl:otherwise>
			</xsl:choose>
		</article>
		
		<xsl:if test="/Document/hasManageAccess">
			
			<div class="of-modal" data-of-modal="update-link">
			
				<a href="#" data-of-close-modal="update-link" class="of-close of-icon of-icon-only">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
					<span><xsl:value-of select="$i18n.Close" /></span>
				</a>
	
				<header>
					<h2 />
				</header>
	
				<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=update" method="post" class="of-form no-auto-scroll">
	
					<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'update'">		
						<div class="validationerrors of-hidden" data-of-open-modal="update-link">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
	
					<xsl:call-template name="createHiddenField">
						<xsl:with-param name="name" select="'linkID'"/>
					</xsl:call-template>
	
					<div>
		
						<label data-of-required="" class="of-block-label">
							<span><xsl:value-of select="$i18n.LinkName" /></span>
							<xsl:call-template name="createTextField">
								<xsl:with-param name="name" select="'name'" />
							</xsl:call-template>
						</label>
		
						<label data-of-required="" class="of-block-label">
							<span><xsl:value-of select="$i18n.URL" /></span>
							<xsl:call-template name="createTextField">
								<xsl:with-param name="name" select="'url'" />
							</xsl:call-template>
						</label>
		
					</div>
		
					<footer class="of-text-right">
						<a href="#" class="submit-btn of-btn of-btn-inline of-btn-gronsta"><xsl:value-of select="$i18n.Save" /></a>
						<span class="of-btn-link">eller <a data-of-close-modal="update-link" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
					</footer>
	
				</form>
	
			</div>
			
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="Link" mode="compact">
		
		<li data-linkid="{linkID}">
			<a href="{url}" class="of-icon of-icon-xs of-icon-absolute-right" target="_blank" title="{$i18n.OpenLinkTitle}">
				<h5><xsl:value-of select="name" /></h5>
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#external"/></svg></i>
			</a>
		</li>
		
	</xsl:template>
	
	<xsl:template match="Link" mode="list">
		
		<li data-linkid="{linkID}" data-name="{name}">
			
			<a name="link{linkID}" />
			
			<xsl:if test="/Document/hasManageAccess">
				<span class="of-todo-tools">
					<a data-of-open-modal="update-link" data-modal-mode="update" href="#"><xsl:value-of select="$i18n.Update" /></a>
					<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/delete/{linkID}" class="of-icon of-icon-only" onclick="return confirm('{$i18n.DeleteLinkConfirm}: {name}?');">
						<i>
							<svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
								<use xlink:href="#trash" />
							</svg>
						</i>
						<span><xsl:value-of select="$i18n.Delete" /></span>
					</a>
				</span>
			</xsl:if>
			<div class="of-checkbox-label of-icon of-icon-xs">
				<a href="{url}" target="_blank"><xsl:value-of select="name" /><xsl:text>&#160;(</xsl:text><xsl:value-of select="url" /><xsl:text>)</xsl:text></a>
				<xsl:text>&#160;&#160;</xsl:text>
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#external"/></svg></i>
			</div>
			<ul class="of-meta-line">
				<li>
					<xsl:value-of select="$i18n.AddedBy" /><xsl:text>&#160;</xsl:text>
					<xsl:call-template name="printUser">
						<xsl:with-param name="user" select="poster" />
					</xsl:call-template>
				</li>
				<li>
					<xsl:value-of select="formattedPostedDate" />
				</li>
				<xsl:if test="formattedUpdatedDate">
					<li>
						<xsl:value-of select="$i18n.UpdatedBy" /><xsl:text>&#160;</xsl:text>
						<xsl:call-template name="printUser">
							<xsl:with-param name="user" select="editor" />
						</xsl:call-template>
					</li>
					<li>
						<xsl:value-of select="formattedUpdatedDate" />
					</li>
				</xsl:if>
			</ul>
			
		</li>
		
	</xsl:template>
	
	<xsl:template match="validationError">
		
		<xsl:if test="fieldName and validationErrorType">
			
			<span class="validationerror" data-parameter="{fieldName}">
				<span class="description error" >
					<xsl:choose>
						<xsl:when test="validationErrorType='RequiredField'">
							<xsl:value-of select="$i18n.validationError.RequiredField" />
						</xsl:when>
						<xsl:when test="validationErrorType='InvalidFormat'">
							<xsl:value-of select="$i18n.validationError.InvalidFormat" />
						</xsl:when>
						<xsl:when test="validationErrorType='TooShort'">
							<xsl:value-of select="$i18n.validationError.TooShort" />
						</xsl:when>
						<xsl:when test="validationErrorType='TooLong'">
							<xsl:value-of select="$i18n.validationError.TooLong" />
						</xsl:when>
						<xsl:when test="validationErrorType='Other'">
							<xsl:value-of select="$i18n.validationError.Other" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$i18n.validationError.unknownValidationErrorType" />
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#error"/></svg></i>
			</span>
		</xsl:if>
		<xsl:if test="messageKey">
			
				<xsl:choose>
					<xsl:when test="messageKey=''">
						
					</xsl:when>
					<xsl:otherwise>
						<p class="error"><xsl:value-of select="$i18n.validationError.unknownMessageKey" />!</p>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:if>
		<xsl:apply-templates select="message" />
		
	</xsl:template>
	
	<xsl:template name="printUser">
		
		<xsl:param name="user" />
		
		<xsl:choose>
			<xsl:when test="$user"><xsl:value-of select="$user/firstname" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$user/lastname" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$i18n.DeletedUser" /></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
</xsl:stylesheet>