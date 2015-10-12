<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="scriptPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/js</xsl:variable>
	<xsl:variable name="imagePath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/pics</xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/settingsmodule.js	
	</xsl:variable>

	<xsl:template match="Document">
		
		<div class="contentitem of-module">
			
			<xsl:apply-templates select="SectionSettings" />
			
		</div>
		
	</xsl:template>
	
	<xsl:template match="SectionSettings">
		
		<div class="of-block">
			<header class="of-inner-padded-trl">
			
				<xsl:if test="DeleteSectionURI">
					<div class="of-right">
						<a class="of-btn of-btn-rodon of-btn-xs of-btn-inline of-icon" href="{DeleteSectionURI}">
							<i>
								<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
									<use xlink:href="#trash"/>
								</svg>
							</i>
							<span><xsl:value-of select="$i18n.DeleteSection"/></span>
						</a>
					</div>
				</xsl:if>
			
				<h1>
					<xsl:value-of select="$i18n.SettingsFor"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="/Document/section/name"/>
				</h1>
			</header>

			<xsl:if test="ValidationErrors/validationError">
				<div class="validationerrors of-hidden">
					<xsl:apply-templates select="ValidationErrors/validationError" />
				</div>
			</xsl:if>

			<form method="post" action="{/Document/requestinfo/uri}" enctype="multipart/form-data">

				<article class="of-inner-padded">

					<div class="of-omega-sm of-omega-md of-omega-lg of-omega-xl of-c-xxl-7 of-c-xxxl-8 of-inner-padded-b">

						<h3 class="of-clear-push"><xsl:value-of select="$i18n.ChangeDetails"/></h3>

						<xsl:choose>
						<xsl:when test="Role/manageSectionAccessModeAccess = 'true'">
						
							<label class="of-block-label of-icon">
								<span><xsl:value-of select="$i18n.Name"/></span>
								<input type="text" name="name" value="{/Document/section/name}" />
								<i>
									<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
										<use xlink:href="#lock"/>
									</svg>
								</i>
							</label>
						
						</xsl:when>
						<xsl:otherwise>
						
							<label class="of-block-label of-input-disabled of-icon">
								<span><xsl:value-of select="$i18n.Name"/></span>
								<input type="text" name="name" value="{/Document/section/name}" disabled=""/>
								<i>
									<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
										<use xlink:href="#lock"/>
									</svg>
								</i>
							</label>
						
						</xsl:otherwise>
						</xsl:choose>

						<label class="of-block-label">
							<span><xsl:value-of select="$i18n.Description"/></span>
							<textarea name="description"><xsl:value-of select="section/Attributes/Attribute[Name ='description']/Value"/></textarea>
							<span class="description"><xsl:value-of select="$i18n.MaxDescriptionChars"/></span>
						</label>
						
						<label class="of-block-label">
							<span><xsl:value-of select="$i18n.LogoOrImage"/></span>
						</label>
						
						<xsl:variable name="showLogo" select="HasLogo and not(requestparameters/parameter[name='deleteLogo']/value = 'true')" />
						
						<div class="of-fileupload of-margin-top">
							<xsl:if test="$showLogo">
								<xsl:attribute name="class">of-fileupload of-margin-top of-file-uploaded</xsl:attribute>
							</xsl:if>
							<div class="of-upload">
								<!-- <h2><xsl:value-of select="$i18n.DropFileHere" /></h2> -->
								<input type="file" name="file"></input>
								<span class="of-filesize-info"><xsl:value-of select="$i18n.MaximumFileUpload" /><xsl:text>:&#160;</xsl:text><xsl:value-of select="MaxAllowedFileSize" /></span>
							</div>
							<div class="of-uploaded">
								<xsl:if test="$showLogo">
									<figure>
										<img alt="{/Document/section/name}" src="{SectionLogoURI}" />
									</figure>
									<a href="#" class="of-btn of-btn-vattjom of-btn-sm of-btn-inline"><xsl:value-of select="$i18n.RemoveLogoImage" /></a>
									<xsl:call-template name="createHiddenField">
										<xsl:with-param name="name" select="'deleteLogo'" />
										<xsl:with-param name="value" select="'false'" />
									</xsl:call-template>
								</xsl:if>
							</div>
						</div>						
					</div>

					<div class="of-omega-xs of-omega-sm of-omega-md of-omega-lg of-omega-xl of-c-xxl-3 of-c-xxxl-4 of-inner-padded-b of-omega-xxl-extend">
						
						<xsl:if test="Role/manageModulesAccess = 'true'">

							<h3 class="of-clear-push"><xsl:value-of select="$i18n.EnableDisableModules"/></h3>
						
							<xsl:apply-templates select="SupportedForegroundModules/ForegroundModuleConfiguration[managementMode != 'HIDDEN']"/>
						
						</xsl:if>
						
						<xsl:if test="Role/manageSectionAccessModeAccess = 'true'">

							<div class="of-inner-padded-t-half">
								<div class="of-inner-padded-t-half">
									<h3><xsl:value-of select="$i18n.Secrecy"/></h3>
								</div>
	
								<label class="of-block-label">
									<span><xsl:value-of select="$i18n.Secrecylevel"/></span>
									<span class="description"><xsl:value-of select="$i18n.Secrecylevel.Description"/></span>
								</label>
								
								<label class="of-radio-label of-block-label">
									<xsl:call-template name="createRadio">
										<xsl:with-param name="name" select="'accessMode'"/>
										<xsl:with-param name="value" select="'OPEN'"/>
										<xsl:with-param name="element" select="section/Attributes/Attribute[Name = 'accessMode']"/>
										<xsl:with-param name="elementName" select="'Value'"/>
									</xsl:call-template>
									
									<em class="of-radio"/>
									<span class="of-icon">
										<i title="{$i18n.OpenAccessModeTitle}">
											<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
												<use xlink:href="#eye"/>
											</svg>
										</i>
										<xsl:text>&#160;</xsl:text>
										<span><xsl:value-of select="$i18n.Open"/></span>
									</span>
								</label>
								
								
								<label class="of-radio-label of-block-label">
									<xsl:call-template name="createRadio">
										<xsl:with-param name="name" select="'accessMode'"/>
										<xsl:with-param name="value" select="'CLOSED'"/>
										<xsl:with-param name="element" select="section/Attributes/Attribute[Name = 'accessMode']"/>
										<xsl:with-param name="elementName" select="'Value'"/>
									</xsl:call-template>
									
									<em class="of-radio"/>
									<span class="of-icon">
										<i title="{$i18n.ClosedAccessModeTitle}">
											<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
												<use xlink:href="#lock"/>
											</svg>
										</i>
										<xsl:text>&#160;</xsl:text>
										<span><xsl:value-of select="$i18n.Closed"/></span>
									</span>
								</label>
								
								<label class="of-radio-label of-block-label">
									<xsl:call-template name="createRadio">
										<xsl:with-param name="name" select="'accessMode'"/>
										<xsl:with-param name="value" select="'HIDDEN'"/>
										<xsl:with-param name="element" select="section/Attributes/Attribute[Name = 'accessMode']"/>
										<xsl:with-param name="elementName" select="'Value'"/>
									</xsl:call-template>
									<em class="of-radio"/>
									<span class="of-icon">
										<i title="{$i18n.HiddenAccessModeTitle}">
											<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
												<use xlink:href="#hidden"/>
											</svg>
										</i>
										<xsl:text>&#160;</xsl:text>
										<span><xsl:value-of select="$i18n.Hidden"/></span>
									</span>
								</label>							
	
							</div>
						
						</xsl:if>

						<xsl:if test="Role/manageArchivedAccess = 'true'">

							<div class="of-inner-padded-t-half">
								<div class="of-inner-padded-t-half">
									<h3><xsl:value-of select="$i18n.Status"/></h3>
								</div>
	
								<label class="of-radio-label of-block-label">
									<xsl:call-template name="createRadio">
										<xsl:with-param name="name" select="'archived'"/>
										<xsl:with-param name="value" select="'false'"/>
										<xsl:with-param name="element" select="section"/>
									</xsl:call-template>
									<em class="of-radio"/>
									<span><xsl:value-of select="$i18n.Active"/></span>
								</label>
	
								<label class="of-radio-label of-block-label">
									<xsl:call-template name="createRadio">
										<xsl:with-param name="name" select="'archived'"/>
										<xsl:with-param name="value" select="'true'"/>
										<xsl:with-param name="element" select="section"/>
									</xsl:call-template>
									<em class="of-radio"/>
									<span><xsl:value-of select="$i18n.Archived"/></span>
								</label>
							</div>
						
						</xsl:if>

					</div>

				</article>

				<footer class="of-no-bg of-text-right of-inner-padded">
					<button type="submit" class="of-btn of-btn-inline of-btn-gronsta">Spara ändringar</button>
				</footer>

			</form>
		</div>
		
	</xsl:template>
	
	<xsl:template match="ForegroundModuleConfiguration">
		
		<xsl:variable name="moduleID" select="moduleID"/>
		
		<label class="of-checkbox-label">
			<xsl:call-template name="createCheckbox">
				<xsl:with-param name="name" select="'moduleID'"/>
				<xsl:with-param name="value" select="moduleID"/>
				<xsl:with-param name="requestparameters" select="../../requestparameters"/>
				
				<xsl:with-param name="disabled">
					<xsl:if test="managementMode = 'LOCKED'">
						<xsl:value-of select="'true'"/>
					</xsl:if>
				</xsl:with-param>
				
				<xsl:with-param name="checked">
					<xsl:if test="../../EnabledModules/moduleID = $moduleID">
						<xsl:value-of select="'true'"/>
					</xsl:if>
				</xsl:with-param>				
				
			</xsl:call-template>
			
			<em class="of-checkbox" tabindex="0"><i/></em>
			<span><xsl:value-of select="module/name"/></span>
		</label>
	
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
				<xsl:when test="messageKey='FileSizeLimitExceeded'">
					<span class="validationerror" data-parameter="file">
						<span class="description error" >
							<xsl:value-of select="$i18n.FileSizeLimitExceeded" />
						</span>
					</span>
				</xsl:when>
				<xsl:when test="messageKey='UnableToParseRequest'">
					<span class="validationerror" data-parameter="file">
						<span class="description error" >
							<xsl:value-of select="$i18n.UnableToParseRequest" />
						</span>
					</span>
				</xsl:when>
				<xsl:when test="messageKey='UnableToParseLogoImage'">
					<span class="validationerror" data-parameter="file">
						<span class="description error" >
							<xsl:value-of select="$i18n.UnableToParseLogoImage" />
						</span>
					</span>
				</xsl:when>
				<xsl:when test="messageKey='UnableToDeleteProfileImage'">
					<span class="validationerror" data-parameter="file">
						<span class="description error" >
							<xsl:value-of select="$i18n.UnableToDeleteLogoImage" />
						</span>
					</span>
				</xsl:when>
				<xsl:when test="messageKey='InvalidLogoImageFileFormat'">
					<span class="validationerror" data-parameter="file">
						<span class="description error" >
							<xsl:value-of select="$i18n.InvalidLogoImageFileFormat" />
						</span>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<p class="error"><xsl:value-of select="$i18n.validationError.unknownMessageKey" />!</p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
	</xsl:template>
	
</xsl:stylesheet>