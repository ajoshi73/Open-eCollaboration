<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="SettingsModuleTemplates.xsl"/>

	
	<xsl:variable name="i18n.Description">Beskrivning</xsl:variable>
	
	<xsl:variable name="i18n.MaximumFileUpload">Maximal filstorlek vid uppladdning</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Du måste fylla i fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
	<xsl:variable name="i18n.FileSizeLimitExceeded">Maximal tillåten filstorlek för profilbild överskriden</xsl:variable>
	<xsl:variable name="i18n.UnableToParseRequest">Det gick inte att ladda upp profilbilden</xsl:variable>
	<xsl:variable name="i18n.UnableToParseLogoImage">Det gick inte att ladda upp logotypen</xsl:variable>
	<xsl:variable name="i18n.UnableToDeleteLogoImage">Det gick inte att ta bort logotypen, försök igen</xsl:variable>
	<xsl:variable name="i18n.InvalidLogoImageFileFormat">Otillåtet filformat på logotypen. Tillåtna filtyper är png, jpg, gif och bmp.</xsl:variable>
	
	<xsl:variable name="i18n.MaxDescriptionChars">Max 4000 tecken</xsl:variable>
	<xsl:variable name="i18n.LogoOrImage">Logotyp/Bild</xsl:variable>
	<xsl:variable name="i18n.Secrecy">Sekretess</xsl:variable>
	<xsl:variable name="i18n.Open">Öppet</xsl:variable>
	<xsl:variable name="i18n.Closed">Stängt</xsl:variable>
	<xsl:variable name="i18n.Hidden">Dolt</xsl:variable>
	
	<xsl:variable name="i18n.OpenAccessModeTitle">Öppet rum som alla medarbetare kan se och följa</xsl:variable>
	<xsl:variable name="i18n.ClosedAccessModeTitle">Stängt rum som alla medarbetare kan se, deltagare bjuds in</xsl:variable>
	<xsl:variable name="i18n.HiddenAccessModeTitle">Hemligt rum som endast inbjudna deltagare ser</xsl:variable>
	
	<xsl:variable name="i18n.SettingsFor">Inställningar för</xsl:variable>
	<xsl:variable name="i18n.ChangeDetails">Ändra uppgifter</xsl:variable>
	<xsl:variable name="i18n.Name">Name</xsl:variable>
	<xsl:variable name="i18n.RemoveLogoImage">Ta bort</xsl:variable>
	<xsl:variable name="i18n.EnableDisableModules">Aktivera/avaktivera moduler</xsl:variable>
	<xsl:variable name="i18n.Secrecylevel">Sekretessnivå</xsl:variable>
	<xsl:variable name="i18n.Secrecylevel.Description">Välj en lämplig sekretessnivå för det här samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.Status">Status</xsl:variable>
	<xsl:variable name="i18n.Active">Aktivt</xsl:variable>
	<xsl:variable name="i18n.Archived">Arkiverat</xsl:variable>
	<xsl:variable name="i18n.DeleteSection">Ta bort samarbetsrummet</xsl:variable>
</xsl:stylesheet>
