<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1"/>

	<xsl:template match="document">
		
		<div class="of-absolute-center-wrap">

			<section class="of-omega of-c-sm-fixed-4 of-center">
				<header class="of-icon of-text-center of-inner-padded-t of-inner-padded-b-half">
					<h1 class="of-icon">
						<span><xsl:value-of select="$i18n.Header" /></span>
					</h1>
				</header>
				<div class="of-block of-clear of-padding-mobile">
					<div class="of-inner-padded">
						
						<xsl:apply-templates select="LoginFailed"/>
						<xsl:apply-templates select="AccountDisabled"/>
						<xsl:apply-templates select="AccountLocked"/>
						<xsl:apply-templates select="Login"/>
		
					</div>
				</div>
				<div class="of-text-center">
					<xsl:if test="/document/internalUserLoginFormURL">
						<a href="{/document/internalUserLoginFormURL}"><xsl:value-of select="$i18n.InternalLogin" /></a>
						<xsl:text>&#160;·&#160;</xsl:text>
					</xsl:if>
					<xsl:if test="/document/newPasswordModuleAlias">
						<a id="newPasswordLink" href="{/document/contextpath}{/document/newPasswordModuleAlias}"><xsl:value-of select="$i18n.ForgotPassword" />?</a>
					</xsl:if>
					<div class="of-inner-padded-t-half of-inner-padded-b-half">
						<a href="#" class="of-footer-logo of-login-logo">
						</a>
					</div>
				</div>
			</section>
		</div>
		
	</xsl:template>
	
	<xsl:template match="Login">
		
		<xsl:call-template name="LoginForm"/>
		
	</xsl:template>
	 
	<xsl:template match="AccountDisabled">
		
		<p class="error"><xsl:value-of select="$i18n.AccountDisabled" /></p>
		
	</xsl:template>		
	
	<xsl:template match="AccountLocked">
		
		<p class="error"><xsl:value-of select="$AccountLocked.text.part1"/><xsl:value-of select="."/><xsl:value-of select="$AccountLocked.text.part2"/></p>
		
		<xsl:call-template name="LoginForm"/>
	</xsl:template>		
	
	<xsl:template match="LoginFailed">
	
		<p class="error"><xsl:value-of select="$i18n.LoginFailed" /></p>
		
		<xsl:call-template name="LoginForm"/>
		
	</xsl:template>	
	
	<xsl:template name="LoginForm">
		
		<form class="of-form" method="post" ACCEPT-CHARSET="ISO-8859-1" action="{/document/uri}">
			
			<input type="hidden" name="redirect" value="{/document/redirect}"/>
			
			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.Email" /></span>
				<input type="email" name="username" />
			</label>
			<label class="of-block-label">
				<span><xsl:value-of select="$i18n.Password" /></span>
				<input type="password" name="password" />
			</label>
			<div class="of-clear">
				<div class="of-inner-padded-t-half of-right-from-sm">
					<button class="of-btn of-btn-block of-btn-gronsta" type="submit"><xsl:value-of select="$i18n.Login" /></button>
				</div>
				<!-- <label class="of-checkbox-label">
					<input type="checkbox" />
					<em tabindex="0" class="of-checkbox"></em>
					<span>Kom ihåg mig</span>
				</label> -->
			</div>
		</form>
		
	</xsl:template>	
</xsl:stylesheet>