<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="PageModuleTemplates.xsl"/>

	<xsl:variable name="java.addPageMenuItemName">Skapa sida</xsl:variable>
	<xsl:variable name="java.addPageMenuItemDescription">Skapa undersida till detta rum</xsl:variable>

	<xsl:variable name="i18n.DeletedUser">Borttagen anv�ndare</xsl:variable>

	<xsl:variable name="i18n.AddPage">Skapa ny sida</xsl:variable>
	<xsl:variable name="i18n.UpdatePage">�ndra sida</xsl:variable>
	<xsl:variable name="i18n.LastUpdated">Senast uppdaterad</xsl:variable>
	<xsl:variable name="i18n.by">av</xsl:variable>
	<xsl:variable name="i18n.Title">Rubrik</xsl:variable>
	<xsl:variable name="i18n.Content">Inneh�ll</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.or">eller</xsl:variable>
	<xsl:variable name="i18n.DeletePageConfirm">�r du s�ker p� att du vill ta bort sidan</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	
	<xsl:variable name="i18n.AddAccessDenied">Du har inte r�ttighet att skapa nya sidor med den roll du har!</xsl:variable>
	
	<xsl:variable name="i18n.validationError.RequiredField">F�ltet f�r inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">F�r l�ngt v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">F�r kort v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett ok�nt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett ok�nt fel har uppst�tt</xsl:variable>
	
</xsl:stylesheet>
