<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'SMALL'">
				<xsl:apply-templates select="File" mode="small"/>
			</xsl:when>
			<xsl:when test="Format = 'LARGE'">
				<xsl:apply-templates select="File" mode="large"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:apply-templates select="File" mode="email"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="File" mode="email">
		
		<li>
			<xsl:choose>
				<xsl:when test="../EventType = 'posted'">

					<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="poster"/>
						</xsl:call-template>
					</a>

				</xsl:when>
				<xsl:otherwise>

					<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{editor/userID}">
						<xsl:call-template name="user">
							<xsl:with-param name="user" select="editor"/>
						</xsl:call-template>
					</a>

				</xsl:otherwise>
			</xsl:choose>

			<xsl:text>&#160;</xsl:text>
			
			<xsl:choose>
				<xsl:when test="../EventType = 'posted'">
					<xsl:value-of select="$i18n.HasAddedFile"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n.HasUpdatedFile"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>&#160;</xsl:text>
			
			<a href="{../FileURL}"><xsl:value-of select="filename"/></a>
			
			<xsl:text>&#160;(</xsl:text>

			<xsl:choose>
				<xsl:when test="../EventType = 'posted'">
					<xsl:value-of select="posted"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="updated"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>)</xsl:text>	
		</li>

	</xsl:template>	
	
	<xsl:template match="File" mode="small">
		
		<li>
			<h5>
				<xsl:choose>
					<xsl:when test="../EventType = 'posted'">
						<xsl:value-of select="posted"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="updated"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>:&#160;</xsl:text>
				<span>

					<xsl:choose>
						<xsl:when test="../EventType = 'posted'">

							<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="poster"/>
								</xsl:call-template>
							</a>

						</xsl:when>
						<xsl:otherwise>

							<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{editor/userID}">
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="editor"/>
								</xsl:call-template>
							</a>

						</xsl:otherwise>
					</xsl:choose>

					<xsl:text>&#160;</xsl:text>
					<xsl:choose>
						<xsl:when test="../EventType = 'posted'">
							<xsl:value-of select="$i18n.HasAddedFile"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$i18n.HasUpdatedFile"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>&#160;</xsl:text>
					<a href="{../FileURL}"><xsl:value-of select="filename"/></a>
				</span>
			</h5>
		</li>

	</xsl:template>

	<xsl:template match="File" mode="large">

		<li>
			<figure class="of-profile">
			
				<xsl:choose>
					<xsl:when test="../EventType = 'posted'">

						<xsl:if test="poster and /Document/ProfileImageAlias">
							<img alt="{poster/firstname} {poster/lastname}" src="{/Document/ContextPath}{/Document/ProfileImageAlias}/{poster/userID}" />
						</xsl:if>

					</xsl:when>
					<xsl:otherwise>
						
						<xsl:if test="editor and /Document/ProfileImageAlias">
							<img alt="{editor/firstname} {editor/lastname}" src="{/Document/ContextPath}{/Document/ProfileImageAlias}/{editor/userID}" />
						</xsl:if>						
						
					</xsl:otherwise>
				</xsl:choose>			
			

			</figure>
	
			<article>
				<header>
					<h3>
					
						<xsl:choose>
							<xsl:when test="../EventType = 'posted'">

								<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
									<xsl:call-template name="user">
										<xsl:with-param name="user" select="poster"/>
									</xsl:call-template>
								</a>

							</xsl:when>
							<xsl:otherwise>

								<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{editor/userID}">
									<xsl:call-template name="user">
										<xsl:with-param name="user" select="editor"/>
									</xsl:call-template>
								</a>

							</xsl:otherwise>
						</xsl:choose>					

						<xsl:text> </xsl:text>
						
						<xsl:choose>
							<xsl:when test="../EventType = 'posted'">
								<xsl:value-of select="$i18n.HasAddedFile"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$i18n.HasUpdatedFile"/>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:text> </xsl:text>
						<a href="{../FileURL}"><xsl:value-of select="filename"/></a>
					</h3>
				</header>
	
				<ul class="of-meta-line">
					<li class="of-icon">
						<i>
							<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
								<use xlink:href="#file"></use>
							</svg>
						</i>
						<xsl:value-of select="$i18n.Files"/>
					</li>
					<li>
						<xsl:choose>
							<xsl:when test="../EventType = 'posted'">
								<xsl:value-of select="posted"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="updated"/>
							</xsl:otherwise>
						</xsl:choose>					
					</li>
				</ul>
			</article>
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