<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="PageModuleTemplates.xsl"/>

	<xsl:variable name="java.addPageMenuItemName">Skapa sida</xsl:variable>
	<xsl:variable name="java.addPageMenuItemDescription">Skapa undersida till detta rum</xsl:variable>

	<xsl:variable name="i18n.DeletedUser">Borttagen användare</xsl:variable>

	<xsl:variable name="i18n.AddPage">Skapa ny sida</xsl:variable>
	<xsl:variable name="i18n.UpdatePage">Ändra sida</xsl:variable>
	<xsl:variable name="i18n.LastUpdated">Senast uppdaterad</xsl:variable>
	<xsl:variable name="i18n.by">av</xsl:variable>
	<xsl:variable name="i18n.Title">Rubrik</xsl:variable>
	<xsl:variable name="i18n.Content">Innehåll</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.or">eller</xsl:variable>
	<xsl:variable name="i18n.DeletePageConfirm">Är du säker på att du vill ta bort sidan</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	
	<xsl:variable name="i18n.AddAccessDenied">Du har inte rättighet att skapa nya sidor med den roll du har!</xsl:variable>
	
	<xsl:variable name="i18n.validationError.RequiredField">Fältet får inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
</xsl:stylesheet>
