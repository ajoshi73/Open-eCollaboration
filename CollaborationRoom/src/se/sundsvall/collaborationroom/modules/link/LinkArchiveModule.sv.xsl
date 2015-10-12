<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="LinkArchiveModuleTemplates.xsl"/>

	<xsl:variable name="i18n.NoLinks">Det finns inga länkar.</xsl:variable>
	<xsl:variable name="i18n.DeletedUser">Borttagen användare</xsl:variable>
	<xsl:variable name="i18n.NewLink">Ny länk</xsl:variable>
	<xsl:variable name="i18n.LinkName">Namnge länken</xsl:variable>
	<xsl:variable name="i18n.URL">Adress</xsl:variable>
	
	<xsl:variable name="i18n.Add">Lägg till</xsl:variable>
	<xsl:variable name="i18n.Update">Ändra</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	
	<xsl:variable name="i18n.Close">Stäng</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.Cancel">Avbryt</xsl:variable>
	<xsl:variable name="i18n.DeleteLinkConfirm">Är du säker på att du vill ta bort länken</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">Ändrad av</xsl:variable>
	<xsl:variable name="i18n.OpenLinkTitle">Länken öppnas i nytt fönster</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Fältet får inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Adressen måste börja med http:// eller https://</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
</xsl:stylesheet>
