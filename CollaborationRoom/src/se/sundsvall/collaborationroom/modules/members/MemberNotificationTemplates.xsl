<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'EMAIL'">

				<li>
					<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{user/userID}">
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="user"/>
						</xsl:call-template>
					</a>
				
					<xsl:text>&#160;</xsl:text>
				
					<xsl:call-template name="type"/>
									
					<xsl:text>&#160;</xsl:text>
				
					<a href="{ModuleURL}">
						<strong>
							<xsl:value-of select="SectionName"/>
						</strong>				
					</a>
				
					<xsl:text>&#160;(</xsl:text>
				
					<xsl:value-of select="Added"/>
					
					<xsl:text>)</xsl:text>
				</li>

			</xsl:when>
			<xsl:when test="Format = 'LIST'">
				
					<li>
						<a class="of-icon" href="{ModuleURL}">
							<i>
								<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
									<use xlink:href="#group"/>
								</svg>
							</i>
							<div>
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="user"/>
								</xsl:call-template>
							
								<xsl:text>&#160;</xsl:text>
							
								<xsl:call-template name="type"/>
							
								<xsl:text>&#160;</xsl:text>
							
								<strong>
									<xsl:value-of select="SectionName"/>
								</strong>				
							
								<xsl:text>&#160;</xsl:text>
							
								<ul class="of-meta-line of-meta-line-inline">
									<li><xsl:value-of select="Added"/></li>
								</ul>
							</div>
						</a>
					</li>				
				
			</xsl:when>			
			<xsl:otherwise>

					<li>
						<xsl:if test="Unread">
							<xsl:attribute name="class">new</xsl:attribute>			
						</xsl:if>
					
						<a href="{ModuleURL}">
							<div class="article">
								<p>
									<xsl:call-template name="user">
										<xsl:with-param name="user" select="user"/>
									</xsl:call-template>
								
									<xsl:text>&#160;</xsl:text>
								
									<xsl:call-template name="type"/>
								
									<xsl:text>&#160;</xsl:text>
								
									<strong>
										<xsl:value-of select="SectionName"/>
									</strong>					
								</p>
			
							</div>
							<ul class="of-meta-line">
								<li class="of-icon">
									<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#group"></use></svg></i>
									<span>
										<xsl:value-of select="ModuleName"/>
									</span>
								</li>
								<li><xsl:value-of select="Added"/></li>
							</ul>
						</a>
					</li>

			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
		
	<xsl:template name="type">
	
		<xsl:choose>
			<xsl:when test="Type = 'addedToSection'">
			
				<xsl:value-of select="$i18n.addedToSection"/>
			
			</xsl:when>
			<xsl:when test="Type = 'roleChanged'">
			
				<xsl:value-of select="$i18n.roleChanged"/>
			
			</xsl:when>
			<xsl:otherwise>
			
				<xsl:value-of select="$i18n.removedFromSection"/>
			
			</xsl:otherwise>
		</xsl:choose>
	
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