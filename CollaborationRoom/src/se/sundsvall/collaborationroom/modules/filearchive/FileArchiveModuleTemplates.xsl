<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="scriptPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/js</xsl:variable>
	<xsl:variable name="imagePath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/pics</xsl:variable>

	<xsl:variable name="fileManagerPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/filemanager</xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
		/jquery/jquery-migrate.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/fileupload/jquery.ui.widget.js
		/js/fileupload/jquery.fileupload.js
		/js/fileupload/jquery.iframe-transport.js
		/js/fileupload/jquery.fileupload-process.js
		/js/fileupload/jquery.fileupload-jquery-ui.js
		/js/fileupload/jquery.form.js
		/js/filearchive-fileupload.js
		/utils/js/common.js
		/js/filearchivemodule.js
		/js/js.cookie-1.5.1.min.js
	</xsl:variable>

	<xsl:variable name="links">
		/css/filearchivemodule.css
	</xsl:variable>

	<xsl:template match="Document">

		<xsl:choose>
			<xsl:when test="UploadedFile">
				<xsl:apply-templates select="UploadedFile/File" />				
			</xsl:when>
			<xsl:when test="FileUploadError">
				<xsl:apply-templates select="FileUploadError/validationError" />
			</xsl:when>
			<xsl:otherwise>
				
				<div id="FileArchiveModule" class="contentitem of-module of-block">

					<script type="text/javascript">
						<xsl:if test="allowedFileTypes">
							allowedFileTypes = [<xsl:value-of select="allowedFileTypes" />];
						</xsl:if>
						<xsl:if test="maxFileSize">
							maxFileSize = <xsl:value-of select="maxFileSize" />;
						</xsl:if>
						i18nFileUpload = {
							"INVALID_FILE": '<xsl:value-of select="$i18n.InvalidFileType" />',
							"ALLOWED_FILE_TYPES": '<xsl:value-of select="$i18n.AllowedFileTypes" />',
							"FILE_SIZE_TO_BIG": '<xsl:value-of select="$i18n.FileSizeToBig" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.MaxFileSize" /><xsl:text>&#160;</xsl:text><xsl:value-of select="/Document/formattedMaxFileSize" />',
							"UNKOWN_FILEUPLOAD_ERROR": '<xsl:value-of select="$i18n.UnableToParseFile" />'
						};
						i18nFileUploadModule = {
							"MARKED_FILES_SINGULAR" : '<xsl:value-of select="$i18n.MarkedFilesCount.Singular" />',
							"MARKED_FILES_PLURAL" : '<xsl:value-of select="$i18n.MarkedFilesCount.Plural" />'
						};
					</script>
		
					<xsl:apply-templates select="ListCategories" />
					<xsl:apply-templates select="AttachFiles" />
					
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="ListCategories">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			
			<xsl:if test="/Document/hasManageAccess">
				<div class="of-right">
					<a data-of-toggler="addcategory" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline">
						<span><xsl:value-of select="$i18n.NewCategory" /></span>
					</a>
				</div>
			</xsl:if>
			
			<h2><xsl:value-of select="/Document/module/name" /></h2>
		
		</header>
		
		<div class="of-border-bottom of-inner-padded of-hidden" data-of-toggled="addcategory">
			
			<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=addcategory" method="post" class="of-form">
				
				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'addcategory'">		
					<div class="validationerrors of-hidden">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>
				
				<label data-of-required="" class="of-block-label">
					<span><xsl:value-of select="$i18n.CategoryName" /></span>
					<xsl:call-template name="createTextField">
						<xsl:with-param name="name" select="'name'" />
					</xsl:call-template>
				</label>
	
				<div class="of-text-right of-inner-padded-t-half">
					<button class="submit-btn of-btn of-btn-inline of-btn-gronsta" type="button"><xsl:value-of select="$i18n.Add" /></button>
				</div>
				
			</form>
			
		</div>
		
		<article class="of-inner-padded-rbl of-inner-padded-t-half">
			
			<xsl:choose>
				<xsl:when test="Category">
				
					<div>
						<select id="fileCategoryFilter" data-of-select="inline">
							<option value=""><xsl:value-of select="$i18n.SortOnCategory" /></option>
							
							<xsl:for-each select="Category">
								<option value="{categoryID}"><xsl:value-of select="name" /></option>
							</xsl:for-each>
						</select>
						
						<select id="fileSorter" data-of-select="inline">
							<option value=""><xsl:value-of select="$i18n.SortOn" /></option>
							<option value="name"><xsl:value-of select="$i18n.Filename" /></option>
							<option value="posted"><xsl:value-of select="$i18n.LastCreated" /></option>
							<option value="updated"><xsl:value-of select="$i18n.LastUpdated" /></option>
							<option value="size"><xsl:value-of select="$i18n.Size" /></option>
						</select>
						
						<div class="file-filter">
							<input id="file-filter" type="text" placeholder="{$i18n.FilterByName}" />
						</div>
						
					</div>
					
					<div id="fileCategoryFilterNotice" style="display: none;">
						<div class="floatleft">
							<xsl:value-of select="$i18n.HiddenCategoriesPre" />
							<xsl:text>&#160;</xsl:text>
						</div>
						<span class="floatleft"/>
						<div class="floatleft">
							<xsl:text>&#160;</xsl:text>
							<xsl:value-of select="$i18n.HiddenCategoriesPost" />
						</div>
					</div>
					
					<xsl:apply-templates select="Category" />
				
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n.NoFilesOrCategories" />
				</xsl:otherwise>
			</xsl:choose>
			
		</article>
		
		<xsl:if test="/Document/hasManageAccess">
		
			<xsl:call-template name="createModalDialogs" />
			
			<div id="FileUploadForm" class="of-hidden">
				
				<ul class="of-attachment-template of-hidden">
					
					<li class="file-clone" style="display: none">
						<img data-fileiconbase="{/Document/requestinfo/currentURI}/{/Document/module/alias}/fileicon" /><xsl:text>&#160;</xsl:text>
						<div>
							<span></span>
							<ul class="of-meta-line">
								<li class="filesize"></li>
							</ul>
							<div class="file-form-elements">
								<label class="of-block-label">
									<input type="text" data-gettagsbase="{/Document/requestinfo/currentURI}/{/Document/module/alias}/gettags" name="autocomplete-tags" placeholder="{$i18n.TagFile}" />
									<span class="of-autocomplete-wrap">
									</span>
									<input type="hidden" name="tags" />
								</label>
								<div class="of-inner-padded-t-half progress">
								</div>
							</div>
							<label class="of-block-label error-label" style="display: none" />
						</div>
					</li>
					
					<li class="upload-btns btn-clone" style="display: none">
						<button class="of-icon of-btn of-btn-xs of-btn-gronsta of-btn-inline upload-btn of-right" name="upload" type="button" value="Ladda upp"><i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#upload"></use></svg></i><span>Ladda upp</span></button>
						<button class="of-icon of-btn of-btn-xs of-btn-rodon of-btn-inline cancel cancel-btn of-right" type="button" value="Cancel"><i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#stop"></use></svg></i><span>Avbryt</span></button>
					</li>
					
				</ul>
				
			</div>
			
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="AttachFiles">
		
		<script type="text/javascript">
			attachFiles = true;
		</script>
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			
			<h2><xsl:value-of select="$i18n.AttachFiles" /></h2>
			
			<span class="margintop floatleft"><xsl:value-of select="$i18n.AttachFilesDescription" /></span>
		
		</header>
		
		<article class="of-inner-padded-rbl of-inner-padded-t-half">
			
			<xsl:choose>
				<xsl:when test="Category">
				
					<div>
						<select id="fileCategoryFilter" data-of-select="inline">
							<option value=""><xsl:value-of select="$i18n.SortOnCategory" /></option>
							
							<xsl:for-each select="Category">
								<option value="categoryID"><xsl:value-of select="name" /></option>
							</xsl:for-each>
						</select>
						
						<select id="fileSorter" data-of-select="inline">
							<option value=""><xsl:value-of select="$i18n.SortOn" /></option>
							<option value="name"><xsl:value-of select="$i18n.Filename" /></option>
							<option value="posted"><xsl:value-of select="$i18n.LastCreated" /></option>
							<option value="updated"><xsl:value-of select="$i18n.LastUpdated" /></option>
							<option value="size"><xsl:value-of select="$i18n.Size" /></option>
						</select>
						
						<div class="file-filter">
							<input id="file-filter" type="text" placeholder="{$i18n.FilterByName}" />
						</div>
						
					</div>
					
					<div id="fileCategoryFilterNotice" style="display: none;">
						<div class="floatleft">
							<xsl:value-of select="$i18n.HiddenCategoriesPre" />
							<xsl:text>&#160;</xsl:text>
						</div>
						<span class="floatleft"/>
						<div class="floatleft">
							<xsl:text>&#160;</xsl:text>
							<xsl:value-of select="$i18n.HiddenCategoriesPost" />
						</div>
					</div>
					
					<xsl:apply-templates select="Category">
						<xsl:with-param name="attachFiles" select="true()" />
					</xsl:apply-templates>
				
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n.NoFilesOrCategories" />
				</xsl:otherwise>
			</xsl:choose>
			
			<div id="attachfile-bar" class="attachfile-bar">
				<form method="GET" action="{redirectURI}">
					
					<xsl:if test="requestparameters">
						<xsl:apply-templates select="requestparameters/parameter" mode="attachfiles" />
					</xsl:if>
					
					<input type="submit" class="of-btn of-btn-xs of-btn-gronsta of-btn-inline upload-btn of-right" value="{$i18n.AttachMarkedFiles}" />
					<span id="attached-files-count" class="attached-files-count">Inga markerade filer</span>
					
				</form>
			</div>
			
		</article>
		
		<xsl:if test="/Document/hasManageAccess">
		
			<div id="FileUploadForm" class="of-hidden">
				
				<ul class="of-attachment-template of-hidden">
					
					<li class="file-clone" style="display: none">
						<img data-fileiconbase="{/Document/requestinfo/currentURI}/{/Document/module/alias}/fileicon" /><xsl:text>&#160;</xsl:text>
						<div>
							<span></span>
							<ul class="of-meta-line">
								<li class="filesize"></li>
							</ul>
							<div class="file-form-elements">
								<label class="of-block-label">
									<input type="text" data-gettagsbase="{/Document/requestinfo/currentURI}/{/Document/module/alias}/gettags" name="autocomplete-tags" placeholder="{$i18n.TagFile}" />
									<span class="of-autocomplete-wrap">
									</span>
									<input type="hidden" name="tags" />
								</label>
								<div class="of-inner-padded-t-half progress">
								</div>
							</div>
							<label class="of-block-label error" style="display: none" />
						</div>
					</li>
					
					<li class="upload-btns btn-clone" style="display: none">
						<button class="of-icon of-btn of-btn-xs of-btn-gronsta of-btn-inline upload-btn of-right" name="upload" type="button" value="Ladda upp"><i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#upload"></use></svg></i><span>Ladda upp</span></button>
						<button class="of-icon of-btn of-btn-xs of-btn-rodon of-btn-inline cancel cancel-btn of-right" type="button" value="Cancel"><i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#stop"></use></svg></i><span>Avbryt</span></button>
					</li>
					
				</ul>
				
			</div>
			
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="parameter" mode="attachfiles">
		
		<xsl:call-template name="createHiddenField">
			<xsl:with-param name="name" select="name" />
			<xsl:with-param name="value" select="value" />
		</xsl:call-template>
	
	</xsl:template>
	
	<xsl:template match="Category">
		
		<xsl:param name="attachFiles" select="false()" />
		
		<a name="category{categoryID}" />
		
		<div class="category" data-categoryid="{categoryID}" data-name="{name}">
		
			<xsl:if test="position() != 0">
				<xsl:attribute name="class">category of-inner-padded-t</xsl:attribute>
			</xsl:if>
		
			<header>
				<h3 class="no-padding-rl">
					<xsl:if test="not($attachFiles) and /Document/hasManageAccess and (autoGenerated = 'false' or count(../Category) > 1)">
						
						<nav class="of-toolbox" data-id="1">
							<div>
								<a href="#" class="of-icon of-icon-only" data-of-tooltip="{$i18n.HandleCategory}">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#cog"/></svg></i>
									<span><xsl:value-of select="$i18n.OpenToolbox" /></span>
								</a>
								<ul>
									<li>
										<a href="#" class="of-icon update-category-btn" data-of-open-modal="update-category">
											<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#edit"/></svg></i>
											<span><xsl:value-of select="$i18n.Update" /></span>
										</a>
									</li>
									<li>
										<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/deletecategory/{categoryID}" onclick="return confirm('{$i18n.DeleteCategoryConfirm}: {name}?');" class="of-icon">
											<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#trash"/></svg></i>
											<span><xsl:value-of select="$i18n.Delete" /></span>
										</a>
									</li>
								</ul>
							</div>
						</nav>
					</xsl:if>
					<span><xsl:value-of select="name" /></span>
				</h3>
			</header>
		
			<div>
				
				<ul class="of-attachment-list">
					
					<xsl:choose>
						<xsl:when test="files/File">
							
							<xsl:apply-templates select="files/File">
								<xsl:with-param name="attachFiles" select="$attachFiles" />
							</xsl:apply-templates>
							
						</xsl:when>
						<xsl:otherwise>
								<li class="empty"><span><xsl:value-of select="$i18n.NoFiles" /></span></li>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="/Document/hasManageAccess">
						<li class="upload-files">
							
							<form id="upload-form-{categoryID}" method="post" enctype="multipart/form-data" action="{/Document/requestinfo/currentURI}/{/Document/module/alias}/ajaxuploadfile/{categoryID}">
								<div class="of-fileupload of-margin-top">
									<div class="of-upload">
									
										<span class="title">
											<xsl:value-of select="$i18n.AddFileHelp"/>
										</span>
										
										<span class="btn-upload of-btn of-btn-gronsta of-icon">
										
											<xsl:if test="/Document/EmailDomain">
												<xsl:attribute name="data-of-open-modal">
													<xsl:value-of select="'email-help'"/>
												</xsl:attribute>
											</xsl:if>
										
											<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#plus"/></svg></i>
											<xsl:value-of select="$i18n.NewFile"/>
											
											<xsl:if test="not(/Document/EmailDomain)">
												<input class="fileinput" name="newfile[]" type="file" multiple="multiple" />
											</xsl:if>
											
										</span>
										
										<!-- <span class="of-filesize-info">Maximal filstorlek vid uppladdning: 8mb</span> -->
									</div>
								</div>
								<input class="tags-holder" type="hidden" name="tags" value="" />
							</form>
							
						</li>
					</xsl:if>
					
				</ul>
				
			</div>
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="File">
		
		<xsl:param name="attachFiles" select="false()" />
		
		<xsl:variable name="lowerCaseFilename">
			<xsl:call-template name="toLowerCase">
				<xsl:with-param name="string" select="filename"/>
			</xsl:call-template>
		</xsl:variable>
		
		<li class="file" data-fileid="{fileID}" data-name="{$lowerCaseFilename}" data-posted="{postedInMillis}" data-updated="{updatedInMillis}" data-size="{size}">
			
			<xsl:attribute name="data-tags">
				<xsl:apply-templates select="tags/tag" mode="form" />				
			</xsl:attribute>
			
			<xsl:if test="locked">
				<xsl:attribute name="class">file locked</xsl:attribute>
			</xsl:if>
			
			<a name="file{fileID}" class="anchor" />
			
			<div>
			
				<xsl:if test="not($attachFiles) and /Document/hasManageAccess">
					
					<xsl:variable name="hasLockedAccess" select="locked and lockedBy/userID = /Document/user/userID" />
					
					<xsl:if test="$hasLockedAccess or /Document/hasManageOtherContentAccess or not(locked)">
					
						<nav class="of-toolbox" data-id="{fileID}">
							<div>
								<a href="#" class="of-icon of-icon-only" data-of-tooltip="{$i18n.HandleFile}">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#cog"/></svg></i>
									<span><xsl:value-of select="$i18n.OpenToolbox" /></span>
								</a>
								<ul>
									<xsl:if test="$hasLockedAccess or not(locked)">
										<li>
											<a href="#" class="of-icon update-file-btn" data-of-open-modal="update-file" data-modal-mode="update">
												<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#edit"/></svg></i>
												<span><xsl:value-of select="$i18n.Update" /></span>
											</a>
										</li>
										<li>
											<a href="#" class="of-icon replace-file-btn" data-of-open-modal="replace-file" data-modal-mode="replace">
												<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#file"/></svg></i>
												<span><xsl:value-of select="$i18n.ReplaceFile" /></span>
											</a>
										</li>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="$hasLockedAccess or (locked and /Document/hasManageOtherContentAccess)">
											<li>
												<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/unlockfile/{fileID}" class="of-icon">
													<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#lock"/></svg></i>
													<span><xsl:value-of select="$i18n.UnLockFile" /></span>
												</a>
											</li>
										</xsl:when>
										<xsl:when test="not(locked)">
											<li><a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/lockfile/{fileID}" class="of-icon">
												<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#lock"/></svg></i>
												<span><xsl:value-of select="$i18n.LockFile" /></span>
											</a></li>
										</xsl:when>
									</xsl:choose>
									<xsl:if test="$hasLockedAccess or not(locked)">
										<li>
											<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/deletefile/{fileID}" onclick="return confirm('{$i18n.DeleteFileConfirm}: {filename}?');" class="of-icon">
												<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#trash"/></svg></i>
												<span><xsl:value-of select="$i18n.Delete" /></span>
											</a>
										</li>
									</xsl:if>
								</ul>
							</div>
						</nav>
					
					</xsl:if>
					
				</xsl:if>
				
				<span class="title">
					<span class="locked-overlay"></span>
					<xsl:call-template name="createCheckbox">
						<xsl:with-param name="name" select="'fileID'" />
						<xsl:with-param name="value" select="fileID" />
						<xsl:with-param name="class" select="'of-hidden'" />
						<xsl:with-param name="requestparameters" select="../../../requestparameters" />
					</xsl:call-template>
					<img src="{/Document/requestinfo/currentURI}/{/Document/module/alias}/fileicon/{filename}" /><xsl:text>&#160;</xsl:text>
					<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/downloadfile/{fileID}"><xsl:value-of select="filename" /></a>
				</span>
				
				<ul class="of-meta-line">
					<li>
						<xsl:value-of select="FormattedSize" />
					</li>
					<li>
						<xsl:value-of select="$i18n.AddedBy" /><xsl:text>&#160;</xsl:text>
						<xsl:call-template name="printUser">
							<xsl:with-param name="user" select="poster" />
						</xsl:call-template><xsl:text>:&#160;</xsl:text>
						<xsl:value-of select="formattedPostedDate" />
					</li>
					<xsl:if test="formattedUpdatedDate">
						<li>
							<xsl:value-of select="$i18n.UpdatedBy" /><xsl:text>&#160;</xsl:text>
							<xsl:call-template name="printUser">
								<xsl:with-param name="user" select="editor" />
							</xsl:call-template><xsl:text>:&#160;</xsl:text>
							<xsl:value-of select="formattedUpdatedDate" />
						</li>
					</xsl:if>
					<xsl:if test="formattedLockedDate">
						<li>
							<xsl:value-of select="$i18n.LockedBy" /><xsl:text>&#160;</xsl:text>
							<xsl:call-template name="printUser">
								<xsl:with-param name="user" select="lockedBy" />
							</xsl:call-template><xsl:text>&#160;</xsl:text>
							<xsl:value-of select="$i18n.until" /><xsl:text>:&#160;</xsl:text>
							<xsl:value-of select="formattedLockedDate" />
						</li>
					</xsl:if>
					<xsl:if test="tags">
						<li>
							<xsl:apply-templates select="tags/tag" mode="show" />
						</li>
					</xsl:if>
				</ul>
			
			</div>
			
		</li>
		
	</xsl:template>
	
	<xsl:template name="createModalDialogs">
	
		<div class="of-modal" data-of-modal="update-category">
			
			<a href="#" data-of-close-modal="update-category" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2 />
			</header>

			<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=updatecategory" method="post" class="of-form no-auto-scroll">

				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatecategory'">		
					<div class="validationerrors of-hidden" data-of-open-modal="update-category">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'categoryID'"/>
				</xsl:call-template>

				<div>
					<label data-of-required="" class="of-block-label">
						<span><xsl:value-of select="$i18n.CategoryName" /></span>
						<xsl:call-template name="createTextField">
							<xsl:with-param name="name" select="'name'" />
						</xsl:call-template>
					</label>
				</div>
	
				<footer class="of-text-right">
					<a href="#" class="submit-btn of-btn of-btn-inline of-btn-gronsta"><xsl:value-of select="$i18n.Save" /></a>
					<span class="of-btn-link">eller <a data-of-close-modal="update-task" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
		<div class="of-modal" data-of-modal="update-file">
			
			<a href="#" data-of-close-modal="update-file" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2 />
			</header>

			<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=updatefile" method="post" class="of-form no-auto-scroll">

				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatefile'">		
					<div class="validationerrors of-hidden" data-of-open-modal="update-file">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'fileID'"/>
				</xsl:call-template>

				<div>
					
					<label class="of-block-label">
						<span><xsl:value-of select="$i18n.Tags" /></span>
						<input type="text" data-gettagsbase="{/Document/requestinfo/currentURI}/{/Document/module/alias}/gettags" name="autocomplete-tags"></input>
						<span class="of-autocomplete-wrap">
						</span>
						<input type="hidden" name="tags" />
					</label>
				
					<label class="of-block-label">
						<span><xsl:value-of select="$i18n.Category" /></span>
						<xsl:call-template name="createOFDropdown">
							<xsl:with-param name="name" select="'categoryID'"/>
							<xsl:with-param name="valueElementName" select="'categoryID'" />
							<xsl:with-param name="labelElementName" select="'name'" />
							<xsl:with-param name="element" select="Category"/>
							<xsl:with-param name="showInline" select="false()"/>
						</xsl:call-template>
					</label>
				
				</div>
	
				<footer class="of-text-right">
					<a href="#" class="submit-btn of-btn of-btn-inline of-btn-gronsta"><xsl:value-of select="$i18n.Save" /></a>
					<span class="of-btn-link">eller <a data-of-close-modal="update-file" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
		<div class="of-modal" data-of-modal="replace-file">
			
			<a href="#" data-of-close-modal="replce-file" class="of-close of-icon of-icon-only">
				<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<header>
				<h2><xsl:value-of select="$i18n.ReplaceFile" /></h2>
			</header>

			<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=replacefile" method="post" class="of-form" enctype="multipart/form-data">

				<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'replacefile'">		
					<div class="validationerrors of-hidden" data-of-open-modal="replace-file">
						<xsl:apply-templates select="validationError" />
					</div>
				</xsl:if>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'fileID'"/>
				</xsl:call-template>

				<xsl:call-template name="createHiddenField">
					<xsl:with-param name="name" select="'method'"/>
					<xsl:with-param name="value" select="'replacefile'"/>
				</xsl:call-template>

				<div>
					
					<label class="of-block-label">
						<span><xsl:value-of select="$i18n.ChooseFile" /></span>
						<input type="file" name="newFile" />
					</label>
				
				</div>
	
				<footer class="of-text-right">
					<input type="submit" class="of-btn of-btn-inline of-btn-gronsta" value="{$i18n.Replace}" /><xsl:text>&#160;</xsl:text>
					<span class="of-btn-link">eller <a data-of-close-modal="replace-file" class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
				</footer>

			</form>

		</div>
		
		<xsl:if test="/Document/EmailDomain">
			<div class="of-modal" data-of-modal="email-help">
			
				<a href="#" data-of-close-modal="email-help" class="of-close of-icon of-icon-only">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
					<span><xsl:value-of select="$i18n.Close" /></span>
				</a>
	
				<header>
					<h2>
						<xsl:value-of select="$i18n.EmailHelpTitle" />
					</h2>
				</header>
				
				<div class="HelpTextOrig" style="display: none;">
					<xsl:variable name="helpText">
						<xsl:call-template name="replace-string">
							<xsl:with-param name="text" select="/Document/EmailHelpText"/>
							<xsl:with-param name="from" select="'%EmailAddress'"/>
							<xsl:with-param name="to">
								<xsl:value-of select="'&lt;strong&gt;'"/>
								<xsl:value-of select="/Document/section/sectionID"/>
								<xsl:value-of select="'@'"/>
								<xsl:value-of select="/Document/EmailDomain"/>
								<xsl:value-of select="'&lt;/strong&gt;'"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					
					<xsl:value-of select="$helpText" disable-output-escaping="yes"/>
				</div>
				
				<div class="HelpText"/>
	
				<footer class="of-text-right">
					<a data-of-close-modal="update-file" class="cancel-btn of-btn of-btn-inline of-btn-gronsta" href="#"><xsl:value-of select="$i18n.Cancel" /></a>
				</footer>
	
			</div>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="tag" mode="show">
		
		<xsl:choose>
			<xsl:when test="/Document/SearchModuleAlias">
				<a href="{/Document/requestinfo/contextpath}{/Document/SearchModuleAlias}?t=tag&amp;q={.}"><xsl:text>#</xsl:text><xsl:value-of select="." /></a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>#</xsl:text><xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="position() != last()">
			<xsl:text>,&#160;</xsl:text>
		</xsl:if>
		
	</xsl:template>
	
	
	<xsl:template match="tag" mode="form">
		
		<xsl:value-of select="." /><xsl:if test="position() != last()">, </xsl:if>
	
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
					<xsl:when test="messageKey='InvalidFileFormat'">
						<span class="validationerror" data-parameter="newFile">
							<span class="description error" >
								<xsl:value-of select="$i18n.InvalidFileFormat" /><br/><xsl:value-of select="$i18n.AllowedFileTypes" /><xsl:text>&#160;</xsl:text><xsl:value-of select="/Document/allowedFileTypes" /><xsl:text>.</xsl:text>
							</span>
						</span>
					</xsl:when>
					<xsl:when test="messageKey='UnableToReplaceFile' or messageKey = 'UnableToParseRequest'">
						<span class="validationerror" data-parameter="newFile">
							<span class="description error" >
								<xsl:value-of select="$i18n.UnableToParseFile" />
							</span>
						</span>
					</xsl:when>
					<xsl:when test="messageKey='FileSizeLimitExceeded' or messageKey = 'RequestSizeLimitExceeded'">
						<span class="validationerror" data-parameter="newFile">
							<span class="description error" >
								<xsl:value-of select="$i18n.FileSizeLimitExceeded" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.MaxFileSize" /><xsl:text>&#160;</xsl:text><xsl:value-of select="/Document/formattedMaxFileSize" />
							</span>
						</span>
					</xsl:when>
					<xsl:when test="messageKey='FileSizeToBig'">
						<span class="validationerror" data-parameter="newFile">
							<span class="description error" >
								<xsl:value-of select="$i18n.FileSizeToBig" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.MaxFileSize" /><xsl:text>&#160;</xsl:text><xsl:value-of select="/Document/formattedMaxFileSize" />
							</span>
						</span>
					</xsl:when>
					<xsl:when test="messageKey='NoFileAttached'">
						<span class="validationerror" data-parameter="newFile">
							<span class="description error" >
								<xsl:value-of select="$i18n.NoFileAttached" />
							</span>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<p class="error"><xsl:value-of select="$i18n.validationError.unknownMessageKey" />!</p>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:if>
		<xsl:apply-templates select="message" />
		
	</xsl:template>
	
</xsl:stylesheet>