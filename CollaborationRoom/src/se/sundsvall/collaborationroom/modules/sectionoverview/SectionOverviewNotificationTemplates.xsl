<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />
	
	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'EMAIL'">
				<xsl:call-template name="NameChangeEmail"/>
			</xsl:when>
			<xsl:when test="Format = 'LIST'">
				<xsl:call-template name="NameChangeList"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="NameChangePopup"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="NameChangeEmail">
		
		<li>

			<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{user/userID}">
				<xsl:call-template name="user">
					<xsl:with-param name="user" select="user"/>
				</xsl:call-template>
			</a>

			<xsl:text>&#160;</xsl:text>
			
			<xsl:choose>
				<xsl:when test="NotificationType = 'restored'">
					<xsl:value-of select="$i18n.HasRestoredSection"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n.HasDeletedSection"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>&#160;</xsl:text>
			
			<xsl:choose>
				<xsl:when test="SectionID">
					<a href="{ContextPath}/{SectionID}"><xsl:value-of select="SectionName"/></a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="SectionName"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>&#160;(</xsl:text>
			
			<xsl:value-of select="Posted"/>
			
			<xsl:text>)</xsl:text>
		</li>

	</xsl:template>	
	
	<xsl:template name="NameChangeList">

		<li>
			<a class="of-icon">
			
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="SectionID">
							<xsl:value-of select="ContextPath"/>
							<xsl:value-of select="'/'"/>
							<xsl:value-of select="SectionID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'#'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			
				<i>
					<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
						<use xlink:href="#cog"/>
					</svg>
				</i>
				<div>
					
					<xsl:call-template name="user">
						<xsl:with-param name="user" select="user"/>
					</xsl:call-template>
					
					<xsl:text>&#160;</xsl:text>
					
					<xsl:choose>
						<xsl:when test="NotificationType = 'restored'">
							<xsl:value-of select="$i18n.HasRestoredSection"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$i18n.HasDeletedSection"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:text>&#160;</xsl:text>
					
					<strong>
						<xsl:value-of select="SectionName"/>
					</strong>
					
					<ul class="of-meta-line of-meta-line-inline">
						<li><xsl:value-of select="Posted"/></li>
					</ul>
					
				</div>
			</a>
		</li>

	</xsl:template>
	
	<xsl:template name="NameChangePopup">
		
		<li>
			<xsl:if test="Unread">
				<xsl:attribute name="class">new</xsl:attribute>
			</xsl:if>
		
			<a>
			
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="SectionID">
							<xsl:value-of select="ContextPath"/>
							<xsl:value-of select="'/'"/>
							<xsl:value-of select="SectionID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'#'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			
				<div class="article">
				
					<p>
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="user"/>
						</xsl:call-template>
						
						<xsl:text>&#160;</xsl:text>
						
						<xsl:choose>
							<xsl:when test="NotificationType = 'restored'">
								<xsl:value-of select="$i18n.HasRestoredSection"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$i18n.HasDeletedSection"/>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:text>&#160;</xsl:text>
						
						<strong>
							<xsl:value-of select="SectionName"/>
						</strong>
					</p>
	
				</div>
				<ul class="of-meta-line">
					<li class="of-icon">
						<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#cog"></use></svg></i>
						<span>
							<xsl:value-of select="ModuleName"/>
						</span>
					</li>
					<li><xsl:value-of select="Posted"/></li>
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