<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'EMAIL'">
				<xsl:apply-templates select="Comment" mode="email"/>
			</xsl:when>
			<xsl:when test="Format = 'LIST'">
				<xsl:apply-templates select="Comment" mode="list"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:apply-templates select="Comment" mode="popup"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="Comment" mode="email">
		
		<li>
			<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
				<xsl:call-template name="user">
					<xsl:with-param name="user" select="poster"/>
				</xsl:call-template>
			</a>
		
			<xsl:text>&#160;</xsl:text>
		
			<xsl:value-of select="$i18n.hasCommentedPost"/>
		
			<xsl:text>&#160;</xsl:text>
		
			<a href="{/Document/ContextPath}{/Document/FullAlias}/show/{Post/postID}#c{commentID}">
				<strong>
					<xsl:value-of select="Post/title"/>
				</strong>
			</a>
			
			<xsl:text>&#160;</xsl:text>
		
			<xsl:value-of select="$i18n.in"/>
		
			<xsl:text>&#160;</xsl:text>
		
			<strong>
				<xsl:value-of select="../SectionName"/>
			</strong>				
		
			<xsl:text>&#160;(</xsl:text>
		
			<xsl:value-of select="posted"/>
			
			<xsl:text>)</xsl:text>
		</li>

	</xsl:template>	
	
	<xsl:template match="Comment" mode="list">
		
		<li>
			<a class="of-icon" href="{/Document/ContextPath}{/Document/FullAlias}/show/{Post/postID}#c{commentID}">
				<i>
					<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
						<use xlink:href="#posts"/>
					</svg>
				</i>
				<div>
					<xsl:call-template name="user">
						<xsl:with-param name="user" select="poster"/>
					</xsl:call-template>
				
					<xsl:text>&#160;</xsl:text>
				
					<xsl:value-of select="$i18n.hasCommentedPost"/>
				
					<xsl:text>&#160;</xsl:text>
				
					<strong>
						<xsl:value-of select="Post/title"/>
					</strong>
				
					<xsl:text>&#160;</xsl:text>
				
					<xsl:value-of select="$i18n.in"/>
				
					<xsl:text>&#160;</xsl:text>
				
					<strong>
						<xsl:value-of select="../SectionName"/>
					</strong>				
				
					<xsl:text>&#160;</xsl:text>
				
					<ul class="of-meta-line of-meta-line-inline">
						<li><xsl:value-of select="posted"/></li>
					</ul>
				</div>
			</a>
		</li>

	</xsl:template>

	<xsl:template match="Comment" mode="popup">

		<li>
			<xsl:if test="../Unread">
				<xsl:attribute name="class">new</xsl:attribute>			
			</xsl:if>
		
			<a href="{/Document/ContextPath}{/Document/FullAlias}/show/{Post/postID}#c{commentID}">
				<div class="article">
					<p>
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="poster"/>
						</xsl:call-template>
					
						<xsl:text>&#160;</xsl:text>
					
						<xsl:value-of select="$i18n.hasCommentedPost"/>
					
						<xsl:text>&#160;</xsl:text>
					
						<strong>
							<xsl:value-of select="Post/title"/>
						</strong>
					
						<xsl:text>&#160;</xsl:text>
					
						<xsl:value-of select="$i18n.in"/>
					
						<xsl:text>&#160;</xsl:text>
					
						<strong>
							<xsl:value-of select="../SectionName"/>
						</strong>					
					</p>

					<blockquote>
						<figure class="of-profile">
							<xsl:if test="poster and /Document/ProfileImageAlias">
								<img alt="{poster/firstname} {poster/lastname}" src="{/Document/ContextPath}{/Document/ProfileImageAlias}/{poster/userID}" />
							</xsl:if>
						</figure>
						<span>
							<xsl:call-template name="replaceLineBreak">
								<xsl:with-param name="string" select="message"/>
							</xsl:call-template>
						</span>
					</blockquote>
				</div>
				<ul class="of-meta-line">
					<li class="of-icon">
						<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#posts"></use></svg></i>
						<span>
							<xsl:value-of select="../ModuleName"/>
						</span>
					</li>
					<li><xsl:value-of select="posted"/></li>
				</ul>
			</a>
		</li>

	</xsl:template>
	
	<xsl:template name="user">
		
		<xsl:param name="user"/>
		
		<xsl:choose>
			<xsl:when test="$user">
				<xsl:value-of select="$user/firstname"/>
				<xsl:text>&#x20;</xsl:text>
				<xsl:value-of select="$user/lastname"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$i18n.DeletedUser"/>
			</xsl:otherwise>
		</xsl:choose> 	
	</xsl:template>	
	
</xsl:stylesheet>