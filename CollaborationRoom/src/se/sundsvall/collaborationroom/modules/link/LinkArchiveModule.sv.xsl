<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="LinkArchiveModuleTemplates.xsl"/>

	<xsl:variable name="i18n.NoLinks">Det finns inga l�nkar.</xsl:variable>
	<xsl:variable name="i18n.DeletedUser">Borttagen anv�ndare</xsl:variable>
	<xsl:variable name="i18n.NewLink">Ny l�nk</xsl:variable>
	<xsl:variable name="i18n.LinkName">Namnge l�nken</xsl:variable>
	<xsl:variable name="i18n.URL">Adress</xsl:variable>
	
	<xsl:variable name="i18n.Add">L�gg till</xsl:variable>
	<xsl:variable name="i18n.Update">�ndra</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	
	<xsl:variable name="i18n.Close">St�ng</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.Cancel">Avbryt</xsl:variable>
	<xsl:variable name="i18n.DeleteLinkConfirm">�r du s�ker p� att du vill ta bort l�nken</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">�ndrad av</xsl:variable>
	<xsl:variable name="i18n.OpenLinkTitle">L�nken �ppnas i nytt f�nster</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">F�ltet f�r inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Adressen m�ste b�rja med http:// eller https://</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">F�r l�ngt v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">F�r kort v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett ok�nt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett ok�nt fel har uppst�tt</xsl:variable>
	
</xsl:stylesheet>
