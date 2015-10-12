<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/CKEditor.xsl" />

	<xsl:variable name="scriptPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/js</xsl:variable>
	<xsl:variable name="imagePath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/pics</xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
		/ckeditor/ckeditor.js
		/ckeditor/adapters/jquery.js
		/ckeditor/init.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/utils/js/common.js
		/js/pagemodule.js
	</xsl:variable>

	<xsl:variable name="links">
	</xsl:variable>

	<xsl:template match="Document">
		
		<div id="PageModule" class="contentitem of-module of-block">
			
			<xsl:apply-templates select="AddPage" />
			<xsl:apply-templates select="ShowPage" />
			
		</div>
		
	</xsl:template>
	
	<xsl:template match="AddPage">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			<h2><xsl:value-of select="$i18n.AddPage" /></h2>
		</header>
		
		<xsl:choose>
			<xsl:when test="/Document/hasAddAccess">
				<form action="{/Document/requestinfo/uri}" method="post" class="of-form">
					
					<xsl:if test="validationException/validationError">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationException/validationError" />
						</div>
					</xsl:if>
				
					<xsl:call-template name="createPageForm" />
				
				</form>
			</xsl:when>
			<xsl:otherwise>
				<div class="of-inner-padded-rl of-inner-padded-tb-half">
					<p><xsl:value-of select="$i18n.AddAccessDenied" /></p>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="ShowPage">
		
		<xsl:if test="hasUpdateAccess">
		
			<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
				<div class="of-right">
					<a data-of-toggler="edit" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline">
						<span><xsl:value-of select="$i18n.UpdatePage" /></span>
					</a>
				</div>
			</header>
			
			<div data-of-toggled="edit" class="of-border-bottom of-hidden">
				<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}/show/{Page/pageID}?method=update" method="post" data-method="update" class="of-form">
					
					<xsl:if test="validationError">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
					
					<xsl:call-template name="createPageForm">
						<xsl:with-param name="page" select="Page" />					
					</xsl:call-template>
					
				</form>
			</div>
		
		</xsl:if>
		
		<header class="of-inner-padded-rl of-inner-padded-t-half">
			<h1 class="of-h1"><xsl:value-of select="Page/title" /></h1>
		</header>
		
		<div class="of-inner-padded-rl of-inner-padded-tb-half">

			<xsl:value-of select="Page/content" disable-output-escaping="yes" />
	
			<div class="of-inner-padded-tb-half">
				<ul class="of-meta-line">
					<li>
						<xsl:value-of select="$i18n.LastUpdated" /><xsl:text>&#160;</xsl:text>
						<xsl:choose>
							<xsl:when test="Page/formattedUpdatedDate">
								<xsl:value-of select="Page/formattedUpdatedDate" />
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="$i18n.by" />
								<xsl:text>&#160;</xsl:text>
								<xsl:call-template name="printUser">
									<xsl:with-param name="user" select="Page/editor" />		
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="Page/formattedPostedDate" />
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="$i18n.by" />
								<xsl:text>&#160;</xsl:text>
								<xsl:call-template name="printUser">
									<xsl:with-param name="user" select="Page/poster" />		
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</ul>
			</div>
	
		</div>
		
	</xsl:template>
	
	<xsl:template name="createPageForm">
		
		<xsl:param name="page" select="null" />
		
		<div class="of-inner-padded-rl of-inner-padded-tb-half">
			<label class="of-block-label" data-of-required="">
				<span><xsl:value-of select="$i18n.Title" /></span>
				<xsl:call-template name="createTextField">
					<xsl:with-param name="id" select="'updatepage_title'"/>
					<xsl:with-param name="name" select="'title'"/>
					<xsl:with-param name="title" select="$i18n.Title"/>
					<xsl:with-param name="element" select="$page" />
				</xsl:call-template>
			</label>

			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.Content" /></span>
				<div class="of-auto-resize-clone" style="">
					<br class="lbr" />
				</div>
				<xsl:call-template name="createTextArea">
					<xsl:with-param name="id" select="'updatepage_content'"/>
					<xsl:with-param name="name" select="'content'"/>
					<xsl:with-param name="title" select="$i18n.Content"/>
					<xsl:with-param name="class" select="'of-auto-resize fckeditor'"/>
					<xsl:with-param name="element" select="$page" />
				</xsl:call-template>
			</label>

			<div class="of-inner-padded-tb-half of-text-right">
				<button class="of-btn of-btn-gronsta of-btn-inline submit-btn" type="submit"><xsl:value-of select="$i18n.Save" /></button>
				<xsl:if test="$page">
					<span class="of-btn-link">
						<xsl:value-of select="$i18n.or" /><xsl:text>&#160;</xsl:text>
						<a onclick="return confirm('{$i18n.DeletePageConfirm}: {$page/title}?');" href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/delete/{$page/pageID}"><xsl:value-of select="$i18n.Delete" /></a>
					</span>
				</xsl:if>
			</div>

		</div>
	
		<xsl:call-template name="initFCKEditor" />
	
	</xsl:template>
	
	<xsl:template name="initFCKEditor">
		
		<xsl:call-template name="initializeFCKEditor">
			<xsl:with-param name="basePath"><xsl:value-of select="/Document/requestinfo/contextpath"/>/static/f/<xsl:value-of select="/Document/module/sectionID"/>/<xsl:value-of select="/Document/module/moduleID"/>/ckeditor/</xsl:with-param>
			<xsl:with-param name="customConfig">ckeditor-config.js</xsl:with-param>
			<xsl:with-param name="editorContainerClass">fckeditor</xsl:with-param>
			<xsl:with-param name="editorHeight">400</xsl:with-param>
			<xsl:with-param name="filebrowserBrowseUri">filemanager/index.html?Connector=<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/connector</xsl:with-param>
			<xsl:with-param name="filebrowserImageBrowseUri">filemanager/index.html?Connector=<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/connector</xsl:with-param>
			<xsl:with-param name="contentsCss">
				<xsl:if test="/Document/cssPath">
					<xsl:value-of select="/Document/requestinfo/contextpath" /><xsl:value-of select="/Document/cssPath"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template name="printUser">
		
		<xsl:param name="user" />
		
		<xsl:choose>
			<xsl:when test="$user"><xsl:value-of select="$user/firstname" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$user/lastname" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$i18n.DeletedUser" /></xsl:otherwise>
		</xsl:choose>
		
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
	
</xsl:stylesheet>