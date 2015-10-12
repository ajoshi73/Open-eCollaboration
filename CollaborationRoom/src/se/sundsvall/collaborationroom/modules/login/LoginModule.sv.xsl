<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="LoginModuleTemplates.xsl" />
	
	<xsl:variable name="i18n.Header" select="'Samarbetsrum'" />
	<xsl:variable name="i18n.AccountDisabled" select="'Ditt konto �r avst�ngt, kontakta systemadministrat�ren f�r mer information.'" />
	<xsl:variable name="i18n.LoginFailed" select="'Felaktigt anv�ndarnamn eller l�senord!'" />
	
	<xsl:variable name="AccountLocked.text.part1" select="'Kontot �r l�st i '" />
	<xsl:variable name="AccountLocked.text.part2" select="' minuter p.g.a f�r m�nga felaktiga inloggningsf�rs�k!'" />	
	
	<xsl:variable name="i18n.Email" select="'E-postadress'" />
	<xsl:variable name="i18n.Password" select="'L�senord'" />
	<xsl:variable name="i18n.Login" select="'Logga in'" />
	<xsl:variable name="i18n.ForgotPassword">Gl�mt l�senord</xsl:variable>
	<xsl:variable name="i18n.InternalLogin">Logga in som medarbetare</xsl:variable>
	
</xsl:stylesheet>