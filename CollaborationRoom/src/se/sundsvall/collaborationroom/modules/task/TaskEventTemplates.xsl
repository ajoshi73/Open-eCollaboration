<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<xsl:choose>
			<xsl:when test="Format = 'SMALL'">
				<xsl:apply-templates select="Task" mode="small"/>
			</xsl:when>
			<xsl:when test="Format = 'LARGE'">
				<xsl:apply-templates select="Task" mode="large"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:apply-templates select="Task" mode="email"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="Task" mode="email">
		
		<li>
			<span>

				<xsl:choose>
					<xsl:when test="../EventType = 'added'">

						<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
							<xsl:call-template name="user">
								<xsl:with-param name="user" select="poster"/>
							</xsl:call-template>
						</a>

					</xsl:when>
					<xsl:otherwise>

						<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{finishedByUser/userID}">
							<xsl:call-template name="user">
								<xsl:with-param name="user" select="finishedByUser"/>
							</xsl:call-template>
						</a>

					</xsl:otherwise>
				</xsl:choose>

				<xsl:text>&#160;</xsl:text>
				
				<xsl:choose>
					<xsl:when test="../EventType = 'added'">
						<xsl:value-of select="$i18n.HasAddedTask"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$i18n.HasCompletedTask"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:text>&#160;</xsl:text>
				
				<a href="{../TaskURL}"><xsl:value-of select="title"/></a>
			</span>
			
			<xsl:text>:&#160;(</xsl:text>
			
			<xsl:choose>
				<xsl:when test="../EventType = 'added'">
					<xsl:value-of select="posted"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="finished"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:text>)</xsl:text>		
		</li>

	</xsl:template>	
	
	<xsl:template match="Task" mode="small">
		
		<li>
			<h5>
				<xsl:choose>
					<xsl:when test="../EventType = 'added'">
						<xsl:value-of select="posted"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="finished"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>:&#160;</xsl:text>
				<span>

					<xsl:choose>
						<xsl:when test="../EventType = 'added'">

							<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="poster"/>
								</xsl:call-template>
							</a>

						</xsl:when>
						<xsl:otherwise>

							<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{finishedByUser/userID}">
								<xsl:call-template name="user">
									<xsl:with-param name="user" select="finishedByUser"/>
								</xsl:call-template>
							</a>

						</xsl:otherwise>
					</xsl:choose>

					<xsl:text>&#160;</xsl:text>
					<xsl:choose>
						<xsl:when test="../EventType = 'added'">
							<xsl:value-of select="$i18n.HasAddedTask"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$i18n.HasCompletedTask"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>&#160;</xsl:text>
					<a href="{../TaskURL}"><xsl:value-of select="title"/></a>
				</span>
			</h5>
		</li>

	</xsl:template>

	<xsl:template match="Task" mode="large">

		<li>
			<figure class="of-profile">
			
				<xsl:choose>
					<xsl:when test="../EventType = 'added'">

						<xsl:if test="poster and /Document/ProfileImageAlias">
							<img alt="{poster/firstname} {poster/lastname}" src="{/Document/ContextPath}{/Document/ProfileImageAlias}/{poster/userID}" />
						</xsl:if>

					</xsl:when>
					<xsl:otherwise>
						
						<xsl:if test="finishedByUser and /Document/ProfileImageAlias">
							<img alt="{finishedByUser/firstname} {finishedByUser/lastname}" src="{/Document/ContextPath}{/Document/ProfileImageAlias}/{finishedByUser/userID}" />
						</xsl:if>						
						
					</xsl:otherwise>
				</xsl:choose>			
			

			</figure>
	
			<article>
				<header>
					<h3>
					
						<xsl:choose>
							<xsl:when test="../EventType = 'added'">

								<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{poster/userID}">
									<xsl:call-template name="user">
										<xsl:with-param name="user" select="poster"/>
									</xsl:call-template>
								</a>

							</xsl:when>
							<xsl:otherwise>

								<a href="{/Document/ContextPath}{/Document/ShowProfileAlias}/{finishedByUser/userID}">
									<xsl:call-template name="user">
										<xsl:with-param name="user" select="finishedByUser"/>
									</xsl:call-template>
								</a>

							</xsl:otherwise>
						</xsl:choose>					

						<xsl:text> </xsl:text>
						
						<xsl:choose>
							<xsl:when test="../EventType = 'added'">
								<xsl:value-of select="$i18n.HasAddedTask"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$i18n.HasCompletedTask"/>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:text> </xsl:text>
						<a href="{../TaskURL}"><xsl:value-of select="title"/></a>
					</h3>
				</header>
	
				<ul class="of-meta-line">
					<li class="of-icon">
						<i>
							<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
								<use xlink:href="#posts"></use>
							</svg>
						</i>
						<xsl:value-of select="$i18n.Tasks"/>
					</li>
					<li>
						<xsl:choose>
							<xsl:when test="../EventType = 'added'">
								<xsl:value-of select="posted"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="finished"/>
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