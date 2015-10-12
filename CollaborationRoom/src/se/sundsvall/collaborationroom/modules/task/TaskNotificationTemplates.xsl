<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'EMAIL'">
				<xsl:apply-templates select="Task" mode="email"/>
			</xsl:when>
			<xsl:when test="Format = 'LIST'">
				<xsl:apply-templates select="Task" mode="list"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:apply-templates select="Task" mode="popup"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="Task" mode="email">
		
		<li>
		
			<xsl:choose>
				<xsl:when test="editor">
				
					<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{editor/userID}">
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="editor"/>
						</xsl:call-template>
					</a>
					
				</xsl:when>
				<xsl:otherwise>
				
					<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="poster"/>
						</xsl:call-template>
					</a>
					
				</xsl:otherwise>
			</xsl:choose>
				
			<xsl:text>&#160;</xsl:text>
		
			<xsl:value-of select="$i18n.hasAssignedTask"/>
		
			<xsl:text>&#160;</xsl:text>
		
			<a href="{../TaskURL}">
				<strong>
					<xsl:value-of select="title"/>
				</strong>
			</a>
		
			<xsl:text>&#160;</xsl:text>
		
			<xsl:value-of select="$i18n.in"/>
		
			<xsl:text>&#160;</xsl:text>
		
			<strong>
				<xsl:value-of select="../SectionName"/>
			</strong>				
		
			<xsl:text>&#160;(</xsl:text>
		
			<xsl:choose>
				<xsl:when test="updated">
					<xsl:value-of select="updated"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="posted"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>)</xsl:text>
		</li>

	</xsl:template>	
	
	<xsl:template match="Task" mode="list">
	
		<li>
			<a class="of-icon" href="{../TaskURL}">
				<i>
					<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
						<use xlink:href="#checkmark"/>
					</svg>
				</i>
				<div>
				
				<xsl:choose>
					<xsl:when test="editor">
					
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="editor"/>
						</xsl:call-template>
						
					</xsl:when>
					<xsl:otherwise>
					
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="poster"/>
						</xsl:call-template>
						
					</xsl:otherwise>
				</xsl:choose>
				
					<xsl:text>&#160;</xsl:text>
				
					<xsl:value-of select="$i18n.hasAssignedTask"/>
				
					<xsl:text>&#160;</xsl:text>
				
					<strong>
						<xsl:value-of select="title"/>
					</strong>
				
					<xsl:text>&#160;</xsl:text>
				
					<xsl:value-of select="$i18n.in"/>
				
					<xsl:text>&#160;</xsl:text>
				
					<strong>
						<xsl:value-of select="../SectionName"/>
					</strong>				
				
					<xsl:text>&#160;</xsl:text>
				
					<ul class="of-meta-line of-meta-line-inline">
						<li>
							<xsl:choose>
								<xsl:when test="updated">
									<xsl:value-of select="updated"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="posted"/>
								</xsl:otherwise>
							</xsl:choose>
						</li>
					</ul>
				</div>
			</a>
		</li>

	</xsl:template>

	<xsl:template match="Task" mode="popup">

		<li>
			<xsl:if test="../Unread">
				<xsl:attribute name="class">new</xsl:attribute>			
			</xsl:if>
		
			<a href="{../TaskURL}">
				<div class="article">
					<p>
						<xsl:choose>
							<xsl:when test="editor">
							
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="editor"/>
								</xsl:call-template>
								
							</xsl:when>
							<xsl:otherwise>
							
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="poster"/>
								</xsl:call-template>
								
							</xsl:otherwise>
						</xsl:choose>
					
						<xsl:text>&#160;</xsl:text>
					
						<xsl:value-of select="$i18n.hasAssignedTask"/>
					
						<xsl:text>&#160;</xsl:text>
					
						<strong>
							<xsl:value-of select="title"/>
						</strong>
					
						<xsl:text>&#160;</xsl:text>
					
						<xsl:value-of select="$i18n.in"/>
					
						<xsl:text>&#160;</xsl:text>
					
						<strong>
							<xsl:value-of select="../SectionName"/>
						</strong>					
					</p>

				</div>
				<ul class="of-meta-line">
					<li class="of-icon">
						<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#checkmark"></use></svg></i>
						<span>
							<xsl:value-of select="../ModuleName"/>
						</span>
					</li>
					<li>
						<xsl:choose>
							<xsl:when test="updated">
								<xsl:value-of select="updated"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="posted"/>
							</xsl:otherwise>
						</xsl:choose>
					</li>
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