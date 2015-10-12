<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="SettingsModuleTemplates.xsl"/>

	
	<xsl:variable name="i18n.Description">Beskrivning</xsl:variable>
	
	<xsl:variable name="i18n.MaximumFileUpload">Maximal filstorlek vid uppladdning</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Du m�ste fylla i f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">F�r l�ngt v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">F�r kort v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett ok�nt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett ok�nt fel har uppst�tt</xsl:variable>
	
	<xsl:variable name="i18n.FileSizeLimitExceeded">Maximal till�ten filstorlek f�r profilbild �verskriden</xsl:variable>
	<xsl:variable name="i18n.UnableToParseRequest">Det gick inte att ladda upp profilbilden</xsl:variable>
	<xsl:variable name="i18n.UnableToParseLogoImage">Det gick inte att ladda upp logotypen</xsl:variable>
	<xsl:variable name="i18n.UnableToDeleteLogoImage">Det gick inte att ta bort logotypen, f�rs�k igen</xsl:variable>
	<xsl:variable name="i18n.InvalidLogoImageFileFormat">Otill�tet filformat p� logotypen. Till�tna filtyper �r png, jpg, gif och bmp.</xsl:variable>
	
	<xsl:variable name="i18n.MaxDescriptionChars">Max 4000 tecken</xsl:variable>
	<xsl:variable name="i18n.LogoOrImage">Logotyp/Bild</xsl:variable>
	<xsl:variable name="i18n.Secrecy">Sekretess</xsl:variable>
	<xsl:variable name="i18n.Open">�ppet</xsl:variable>
	<xsl:variable name="i18n.Closed">St�ngt</xsl:variable>
	<xsl:variable name="i18n.Hidden">Dolt</xsl:variable>
	
	<xsl:variable name="i18n.OpenAccessModeTitle">�ppet rum som alla medarbetare kan se och f�lja</xsl:variable>
	<xsl:variable name="i18n.ClosedAccessModeTitle">St�ngt rum som alla medarbetare kan se, deltagare bjuds in</xsl:variable>
	<xsl:variable name="i18n.HiddenAccessModeTitle">Hemligt rum som endast inbjudna deltagare ser</xsl:variable>
	
	<xsl:variable name="i18n.SettingsFor">Inst�llningar f�r</xsl:variable>
	<xsl:variable name="i18n.ChangeDetails">�ndra uppgifter</xsl:variable>
	<xsl:variable name="i18n.Name">Name</xsl:variable>
	<xsl:variable name="i18n.RemoveLogoImage">Ta bort</xsl:variable>
	<xsl:variable name="i18n.EnableDisableModules">Aktivera/avaktivera moduler</xsl:variable>
	<xsl:variable name="i18n.Secrecylevel">Sekretessniv�</xsl:variable>
	<xsl:variable name="i18n.Secrecylevel.Description">V�lj en l�mplig sekretessniv� f�r det h�r samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.Status">Status</xsl:variable>
	<xsl:variable name="i18n.Active">Aktivt</xsl:variable>
	<xsl:variable name="i18n.Archived">Arkiverat</xsl:variable>
	<xsl:variable name="i18n.DeleteSection">Ta bort samarbetsrummet</xsl:variable>
</xsl:stylesheet>
