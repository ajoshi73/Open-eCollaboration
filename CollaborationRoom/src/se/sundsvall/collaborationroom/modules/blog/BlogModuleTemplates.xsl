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
		/utils/js/common.js
		/js/blogmodule.js
	</xsl:variable>

	<xsl:variable name="links">
	</xsl:variable>

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="LoadAdditionalPosts">
				<xsl:apply-templates select="LoadAdditionalPosts" />
			</xsl:when>
			<xsl:otherwise>
				
				<div class="contentitem of-module of-dialog-block">
			
					<xsl:apply-templates select="ListPosts" />
					<xsl:apply-templates select="LatestPosts" />
					<xsl:apply-templates select="ShowPost" />
					
					<script type="text/javascript">
						blogModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
					</script>
					
				</div>
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="ListPosts">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			<xsl:if test="/Document/hasAddAccess">
				<div class="of-right">
					<a data-of-toggler="new-post" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline">
						<span><xsl:value-of select="$i18n.NewPost" /></span>
					</a>
				</div>
			</xsl:if>
			<h2><xsl:value-of select="/Document/module/name" /></h2>
		</header>
		
		<xsl:if test="/Document/hasAddAccess">
			<div data-of-toggled="new-post" class="of-border-bottom of-inner-padded new-post of-hidden">
				
				<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=addpost" method="post" class="of-form post-form">			
					
					<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'addpost'">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
					
					<xsl:call-template name="createPostForm" />
					<div class="of-inner-padded-t-half of-text-right of-clear">
						<button type="submit" class="of-btn of-btn-gronsta of-btn-inline"><xsl:value-of select="$i18n.Add" /></button>
					</div>
					
				</form>
			</div>
		</xsl:if>
		
		<ul class="of-post-list of-inner-padded-rl">
		
			<script type="text/javascript">
				i18nBlogModule = {
					"READ_MORE": '<xsl:value-of select="$i18n.ReadMore" />',
					"HIDE_TEXT": '<xsl:value-of select="$i18n.HideText" />',
				};
			</script>

			<xsl:choose>
				<xsl:when test="Posts/Post">
					<xsl:apply-templates select="Posts/Post" mode="list" />
				</xsl:when>
				<xsl:otherwise>
					<li class="empty"><xsl:value-of select="$i18n.NoPosts" /></li>
				</xsl:otherwise>
			</xsl:choose>
			
		</ul>
		
		<xsl:if test="Posts/Post">
			<footer>
				<a id="showMoreLink" href="#" class="of-block-link">
					<span><xsl:value-of select="$i18n.ShowMore" /></span>
				</a>
			</footer>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="LoadAdditionalPosts">
		
		<xsl:apply-templates select="Posts/Post" mode="list" />
		
	</xsl:template>

	<xsl:template match="Post" mode="list">
	
		<xsl:param name="sectionName"><xsl:value-of select="/Document/section/name" /></xsl:param>
		<xsl:param name="moduleAlias"><xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" /></xsl:param>
	
		<li data-postid="{postID}">
			
			<a name="p{postID}" />
		
			<xsl:call-template name="createPostToolbar">
				<xsl:with-param name="mode" select="'list'" />
				<xsl:with-param name="moduleAlias" select="$moduleAlias" />
			</xsl:call-template>
			
			<xsl:variable name="postedBy">
				<xsl:call-template name="printUser">
					<xsl:with-param name="user" select="poster" />
				</xsl:call-template>
			</xsl:variable>
			
			<header>
				<figure class="of-profile">
					<xsl:if test="/Document/ProfileImageAlias and poster">
						<img alt="{$postedBy}" src="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}/{poster/userID}" />
					</xsl:if>
				</figure>
				<h2>
					<a id="title_{postID}" href="{$moduleAlias}/show/{postID}"><span><xsl:value-of select="title" /></span></a>
					<span>
						<a href="{/Document/requestinfo/contextpath}{/Document/ShowProfileAlias}/{poster/userID}"><xsl:value-of select="$postedBy" /></a>
						<xsl:text>&#160;</xsl:text>
						<i class="of-inline-arrow"><svg viewBox="0 0 640 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#arrow-right"/></svg></i>
						<xsl:text>&#160;</xsl:text>
						<a href="{$moduleAlias}/show/{postID}"><xsl:value-of select="$sectionName" /></a>
					</span>
				</h2>
			</header>
			<div class="article">
				<span id="message_{postID}" class="of-show-more article-content" style="display: none">
					<xsl:call-template name="replaceLineBreaksAndLinks">
						<xsl:with-param name="string" select="message"/>
					</xsl:call-template>
				</span>
				
				<xsl:apply-templates select="AttachedFiles" />
				
				<ul class="of-meta-line">
					<li class="of-hide-to-sm"><a href="{$moduleAlias}/show/{postID}#comment">Kommentera (<xsl:value-of select="commentCount" />)</a></li>
					<li>
						<xsl:value-of select="formattedPostedDate" />
						<xsl:if test="formattedUpdatedDate">
							<xsl:text>&#160;·&#160;</xsl:text><xsl:value-of select="$i18n.Updated" /><xsl:text>:&#160;</xsl:text><xsl:value-of select="formattedUpdatedDate" />		
						</xsl:if>
					</li>
					<xsl:if test="tags">
						<li>
							<xsl:apply-templates select="tags/tag" mode="show" />
						</li>
					</xsl:if>
				</ul>
			</div>
			
			<footer class="of-hide-from-sm">
				<a href="{$moduleAlias}/show/{postID}" class="of-block-link"><xsl:value-of select="$i18n.AddComment" /><xsl:text>&#160;</xsl:text>(<xsl:value-of select="commentCount" />)</a>
			</footer>

		</li>
	
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
	
	<xsl:template match="ShowPost">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			<div class="of-right">
				<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}" class="of-btn of-btn-outline of-btn-xs of-btn-inline of-icon of-icon-xs">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#arrow-left"/></svg></i>
					<span><xsl:value-of select="$i18n.Back" /></span>
				</a>
			</div>
			
			<h2><xsl:value-of select="/Document/module/name" /></h2>
			
			<xsl:if test="Post/hasUpdateAccess">
				<div id="update-post-form" class="of-inner-padded-tb of-hidden">
					<h2><xsl:value-of select="$i18n.UpdatePost" /></h2>
					<form action="{/Document/requestinfo/uri}?method=updatepost" method="post" class="of-form post-form">
						
						<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatepost'">		
							<div class="validationerrors of-hidden">
								<xsl:apply-templates select="validationError" />
							</div>
						</xsl:if>
						
						<xsl:call-template name="createPostForm">
							<xsl:with-param name="post" select="Post" />
						</xsl:call-template>
						<div class="of-inner-padded-t-half of-text-right of-clear">
							<button type="submit" class="of-btn of-btn-gronsta of-btn-inline"><xsl:value-of select="$i18n.Save" /></button>
							<span class="of-btn-link"><xsl:value-of select="$i18n.or" /><xsl:text>&#160;</xsl:text><a class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
						</div>
					</form>
				</div>
			</xsl:if>
		</header>
		
		<xsl:apply-templates select="Post" mode="show" />
		
	</xsl:template>
	
	<xsl:template name="createPostForm">
		
		<xsl:param name="post" select="null" />
	
		<label data-of-required="" class="of-block-label">	
			<span><xsl:value-of select="$i18n.Title" /></span>
			<xsl:call-template name="createTextField">
				<xsl:with-param name="id" select="'updatepost_title'"/>
				<xsl:with-param name="name" select="'title'"/>
				<xsl:with-param name="element" select="$post" />
			</xsl:call-template>
		</label>

		<label data-of-required="" class="of-block-label">
			<span><xsl:value-of select="$i18n.Message" /></span>
			<div class="of-auto-resize-clone" style=""><br class="lbr" /></div>
			<xsl:call-template name="createTextArea">
				<xsl:with-param name="id" select="'updatepost_message'"/>
				<xsl:with-param name="name" select="'message'"/>
				<xsl:with-param name="class" select="'of-auto-resize'" />
				<xsl:with-param name="element" select="$post" />
			</xsl:call-template>
		</label>

		<label class="of-block-label">
			<span><xsl:value-of select="$i18n.TagPost" /></span>
			<input type="text" data-of-autocomplete="{/Document/requestinfo/currentURI}/{/Document/module/alias}/gettags" name="autocomplete-tags">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="requestparameters">
							<xsl:value-of select="requestparameters/parameter[name='tags']/value" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$post/tags/tag" mode="form" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</input>
			<span class="of-autocomplete-wrap">
			</span>
			<input type="hidden" name="tags" />
		</label>

		<a name="attachedfiles" />

		<xsl:if test="/Document/FileArchiveModuleAlias">
		
			<div class="of-inner-padded-t-half">
				<div class="of-inline of-hide-to-md">
					<a id="attach-file-link" href="#" class="of-icon" data-attachfileuri="{/Document/requestinfo/contextpath}{/Document/FileArchiveModuleAlias}/attachfiles">
						<xsl:call-template name="createHiddenField">
							<xsl:with-param name="name" select="'redirectURI'" />
							<xsl:with-param name="value">
								<xsl:choose>
									<xsl:when test="$post">
										<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />/show/<xsl:value-of select="$post/postID" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#file"/></svg></i><span><xsl:value-of select="$i18n.AttachFile" /></span>
					</a>
				</div>
			</div>
		
			<xsl:choose>
				<xsl:when test="AttachedFiles/File">
				
					<ul class="of-attachment-list of-inner-padded-tb-half">
						<xsl:apply-templates select="AttachedFiles/File" mode="form" />
					</ul>
				
					<xsl:if test="requestparameters">
						<script type="text/javascript">
							document.location.hash = 'attachedfiles';
						</script>
					</xsl:if>
				
				</xsl:when>
				<xsl:when test="$post/AttachedFiles/File">
					
					<ul class="of-attachment-list of-inner-padded-tb-half">
						<xsl:apply-templates select="$post/AttachedFiles/File" mode="form" />
					</ul>
				
				</xsl:when>
			</xsl:choose>
		
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="File" mode="form">
		
		<li class="of-icon file">
			<xsl:call-template name="createHiddenField">
				<xsl:with-param name="name" select="'fileID'" />
				<xsl:with-param name="value" select="fileID" />
			</xsl:call-template>
			<div class="of-right">
				<a class="of-icon of-icon-only delete-btn" href="#">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#close"/></svg></i>
					<span><xsl:value-of select="$i18n.Delete" /></span>
				</a>
			</div>
			<div>
				<img src="{/Document/requestinfo/contextpath}{/Document/FileArchiveModuleAlias}/fileicon/{filename}" /><xsl:text>&#160;</xsl:text>
				<a href="{/Document/requestinfo/contextpath}{/Document/FileArchiveModuleAlias}/downloadfile/{fileID}"><xsl:value-of select="filename" /></a>
				<ul class="of-meta-line">
					<li><xsl:value-of select="FormattedSize" /></li>
					<li><xsl:value-of select="Category/name" /></li>
				</ul>
			</div>
		</li>
			
	</xsl:template>
	
	<xsl:template match="AttachedFiles">
	
		<xsl:apply-templates select="File[isImage]" mode="image" />
	
		<xsl:if test="File[not(isImage)]">
			<ul class="of-attachment-list of-inner-padded-tb-half">
				<xsl:apply-templates select="File[not(isImage)]" mode="show" />
			</ul>
		</xsl:if>
	
	</xsl:template>
	
	<xsl:template match="File" mode="show">
		
		<li class="of-icon file small">
			<div>
				<img src="{/Document/requestinfo/contextpath}{/Document/FileArchiveModuleAlias}/fileicon/{filename}" /><xsl:text>&#160;</xsl:text>
				<a href="{/Document/requestinfo/contextpath}{/Document/FileArchiveModuleAlias}/downloadfile/{fileID}"><xsl:value-of select="filename" /></a>
				<ul class="of-meta-line">
					<li><xsl:value-of select="FormattedSize" /></li>
					<li><xsl:value-of select="Category/name" /></li>
				</ul>
			</div>
		</li>
			
	</xsl:template>
	
	<xsl:template match="File" mode="image">
		
		<img src="{/Document/requestinfo/contextpath}{/Document/FileArchiveModuleAlias}/showimage/{fileID}" alt="{filename}" />
		
	</xsl:template>
	
	<xsl:template match="tag" mode="form">
		
		<xsl:value-of select="." /><xsl:if test="position() != last()">, </xsl:if>
	
	</xsl:template>
	
	<xsl:template match="Post" mode="show">
	
		<ul class="of-post-list of-single of-inner-padded-rl">

			<li data-postid="{postID}">
			
				<xsl:call-template name="createPostToolbar">
					<xsl:with-param name="mode" select="'show'" />
				</xsl:call-template>
				
				<xsl:variable name="postedBy">
					<xsl:call-template name="printUser">
						<xsl:with-param name="user" select="poster" />
					</xsl:call-template>
				</xsl:variable>
					
				<header>
					<figure class="of-profile">
						<xsl:if test="/Document/ProfileImageAlias and poster">
							<img alt="{$postedBy}" src="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}/{poster/userID}" />
						</xsl:if>
					</figure>
					<h2>
						<span>
							<xsl:value-of select="title" />
						</span>
						<span>
							<a href="{/Document/requestinfo/contextpath}{/Document/ShowProfileAlias}/{poster/userID}"><xsl:value-of select="$postedBy" /></a>
						</span>
					</h2>
				</header>
				<div class="article">

					<span class="article-content">
						<xsl:call-template name="replaceLineBreaksAndLinks">
							<xsl:with-param name="string" select="message"/>
						</xsl:call-template>
					</span>

					<xsl:apply-templates select="AttachedFiles" />

					<ul class="of-meta-line">
						<li>
							<xsl:value-of select="formattedPostedDate" />
						</li>
						<xsl:if test="formattedUpdatedDate">
							<li><xsl:value-of select="$i18n.Updated" /><xsl:text>:&#160;</xsl:text><xsl:value-of select="formattedUpdatedDate" /></li>	
						</xsl:if>
						<xsl:if test="tags">
							<li>
								<xsl:apply-templates select="tags/tag" mode="show" />
							</li>
						</xsl:if>
					</ul>
				</div>
				
			</li>
			
		</ul>
		
		<div class="comments-wrap">
			<ul class="of-comment-list of-inner-padded-rbl">
				<li class="header">
					<h3><xsl:value-of select="$i18n.Comments" /></h3>
				</li>
				
				<xsl:apply-templates select="comments/Comment" />
				
				<xsl:if test="/Document/hasAddAccess">
					<li class="of-comment-compose of-inner-padded-trl">
						<a name="comment" />
						<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}/show/{postID}?method=addcomment" method="post" class="of-form">
							
							<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'addcomment'">		
								<div class="validationerrors of-hidden">
									<xsl:apply-templates select="validationError" />
								</div>
							</xsl:if>
							
							<figure class="of-profile">
								<xsl:if test="/Document/ProfileImageAlias">
									<img alt="{/Document/user/firstname} {/Document/user/lastname}" src="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}/{/Document/user/userID}" />
								</xsl:if>
							</figure>
							<div class="of-block-label">
								<label>
									<div class="of-auto-resize-clone" style=""><br class="lbr" /></div><textarea id="comment" rows="1" placeholder="{$i18n.AddCommentPlaceHolder}" name="comment" class="of-auto-resize" style="height: 72px;"></textarea>
								</label>
								<div class="of-post-comment of-text-right of-inner-padded-t-half">
									<input type="submit" value="{$i18n.Send}" class="of-btn of-btn-sm of-btn-gronsta of-btn-inline" />
								</div>
							</div>
						</form>
					</li>
				</xsl:if>

			</ul>
		</div>
		
	</xsl:template>

	<xsl:template name="createPostToolbar">

		<xsl:param name="post" select="." />
		<xsl:param name="mode" />
		<xsl:param name="moduleAlias"><xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" /></xsl:param>
		
		<nav class="of-toolbox" data-id="0">
			<div>
				<a href="#" class="of-icon of-icon-only" data-of-tooltip="{$i18n.ManagePost}">
					<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#cog"/></svg></i>
					<span><xsl:value-of select="$i18n.OpenToolbox" /></span>
				</a>
		
				<ul>
					<xsl:choose>
						<xsl:when test="$post/followers[userID = /Document/user/userID]">
							<li>
								<a href="{$moduleAlias}/unfollow/{$post/postID}?mode={$mode}" class="of-icon">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#hidden"/></svg></i>
									<span><xsl:value-of select="$i18n.UnFollow" /></span>
								</a>
							</li>							
						</xsl:when>
						<xsl:otherwise>
							<li>
								<a href="{$moduleAlias}/follow/{$post/postID}?mode={$mode}" class="of-icon">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#eye"/></svg></i>
									<span><xsl:value-of select="$i18n.Follow" /></span>
								</a>
							</li>									
						</xsl:otherwise>
					</xsl:choose>
					<li>
						<a data-of-copy="" href="{/Document/serverURL}{$moduleAlias}/show/{$post/postID}" class="of-icon">
							<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#chain"/></svg></i>
							<span><xsl:value-of select="$i18n.CopyURL" /></span>
						</a>
					</li>
					<xsl:if test="$post/hasUpdateAccess">				
					<li>
						<a href="{$moduleAlias}/show/{$post/postID}#update" class="of-icon">
							<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#edit"/></svg></i>
							<span><xsl:value-of select="$i18n.Update" /></span>
						</a>
					</li>
					</xsl:if>
					<xsl:if test="$post/hasDeleteAccess">
						<li>
							<a href="{$moduleAlias}/deletepost/{$post/postID}"  onclick="return confirm('Är du säker på att du vill ta bort inlägget: {title}?');" class="of-icon">
								<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#trash"/></svg></i>
								<span><xsl:value-of select="$i18n.Delete" /></span>
							</a>
						</li>
					</xsl:if>
					<!-- <li>
						<a data-of-open-modal="report-post" href="#" class="of-icon">
							<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#error"/></svg></i>
							<span>Anmäl</span>
						</a>
					</li> -->
					
				</ul>
			</div>
		</nav>
		
	</xsl:template>
	
	<xsl:template match="Comment">

		<li class="comment">

			<a name="c{commentID}" />

			<xsl:if test="hasUpdateAccess or hasDeleteAccess">
				<nav class="of-toolbox" data-id="1">
					<div>
						<a href="#" class="of-icon of-icon-only" data-of-tooltip="{$i18n.ManageComment}">
							<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#cog"/></svg></i>
							<span><xsl:value-of select="$i18n.OpenToolbox" /></span>
						</a>
				
						<ul>
							<xsl:if test="hasUpdateAccess">
								<li>
									<a href="#" class="of-icon update-comment-btn">
										<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#edit"/></svg></i>
										<span><xsl:value-of select="$i18n.Update" /></span>
									</a>
								</li>
							</xsl:if>
							<xsl:if test="hasDeleteAccess">
								<li>
									<a href="{/Document/requestinfo/currentURI}/{/Document/module/alias}/deletecomment/{commentID}" onclick="return confirm('Är du säker på att du vill ta bort kommentaren?');" class="of-icon">
										<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#trash"/></svg></i>
										<span><xsl:value-of select="$i18n.Delete" /></span>
									</a>
								</li>
							</xsl:if>
							<!-- <li>
								<a data-of-open-modal="report-post" href="#" class="of-icon">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#error"/></svg></i>
									<span>Anmäl</span>
								</a>
							</li>-->
						</ul>
					</div>
				</nav>
			</xsl:if>
			
			<xsl:variable name="postedBy">
				<xsl:call-template name="printUser">
					<xsl:with-param name="user" select="poster" />
				</xsl:call-template>
			</xsl:variable>
			
			<header>
				<figure class="of-profile">
					<xsl:if test="/Document/ProfileImageAlias and poster">
						<img alt="{$postedBy}" src="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}/{poster/userID}" />
					</xsl:if>
				</figure>
				<h2><a href="{/Document/requestinfo/contextpath}{/Document/ShowProfileAlias}/{poster/userID}"><xsl:value-of select="$postedBy" /></a></h2>
			</header>
			
			<div>

				<span class="comment-message">
					<xsl:call-template name="replaceLineBreaksAndLinks">
						<xsl:with-param name="string" select="message"/>
					</xsl:call-template>
				</span>

				<form action="{/Document/requestinfo/uri}?commentID={commentID}&amp;method=updatecomment" method="post" class="of-form of-hidden update-comment-form" data-commentID="{commentID}">
					
					<xsl:if test="validationError and requestparameters/parameter[name = 'method']/value = 'updatecomment'">		
						<div class="validationerrors of-hidden">
							<xsl:apply-templates select="validationError" />
						</div>
					</xsl:if>
					
					<label data-of-required="" class="of-block-label">
						<xsl:call-template name="createTextArea">
							<xsl:with-param name="name" select="'comment'"/>
							<xsl:with-param name="title" select="$i18n.Comment"/>
							<xsl:with-param name="class" select="'of-auto-resize'" />
							<xsl:with-param name="value">
								<xsl:call-template name="replace-string">
									<xsl:with-param name="text" select="message"/>
									<xsl:with-param name="from" select="'&#13;'"/>
									<xsl:with-param name="to" select="''"/>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</label>
					<div class="of-inner-padded-t-half of-text-right of-clear">
						<button type="submit" class="of-btn of-btn-gronsta of-btn-inline"><xsl:value-of select="$i18n.Save" /></button>
						<span class="of-btn-link"><xsl:value-of select="$i18n.or" /><xsl:text>&#160;</xsl:text><a class="cancel-btn" href="#"><xsl:value-of select="$i18n.Cancel" /></a></span>
					</div>
				</form>

				<ul class="of-meta-line">
					<li>
						<xsl:value-of select="formattedPostedDate" />
					</li>
					<xsl:if test="formattedUpdatedDate">
						<li><xsl:value-of select="$i18n.Updated" /><xsl:text>:&#160;</xsl:text><xsl:value-of select="formattedUpdatedDate" /></li>	
					</xsl:if>
				</ul>

			</div>

		</li>
		
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
				<xsl:when test="messageKey='AttachedFileMissing'">
					<span class="validationerror" data-parameter="attachedfiles">
						<span class="description error" >
							<xsl:value-of select="$i18n.validationError.AttachedFileMissing" />
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