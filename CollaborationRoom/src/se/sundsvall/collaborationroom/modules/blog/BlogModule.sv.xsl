<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="BlogModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Skapa inlägg</xsl:variable>

	<xsl:variable name="i18n.NewPost">Nytt inlägg</xsl:variable>

	<xsl:variable name="i18n.DeletedUser">Borttagen användare</xsl:variable>
	
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.Cancel">Avbryt</xsl:variable>
	<xsl:variable name="i18n.Updated">Ändrad</xsl:variable>
	
	<xsl:variable name="i18n.Title">Rubrik</xsl:variable>
	<xsl:variable name="i18n.Message">Meddelande</xsl:variable>
	<xsl:variable name="i18n.Comment">Kommentar</xsl:variable>
	
	<xsl:variable name="i18n.Add">Lägg till</xsl:variable>
	<xsl:variable name="i18n.NoPosts">Det finns ännu inga inlägg</xsl:variable>
	<xsl:variable name="i18n.ShowMore">Visa fler</xsl:variable>
	<xsl:variable name="i18n.AddComment">Kommentera</xsl:variable>
	<xsl:variable name="i18n.Back">Visa alla inlägg</xsl:variable>
	<xsl:variable name="i18n.UpdatePost">Ändra inlägg</xsl:variable>
	<xsl:variable name="i18n.TagPost">Tagga inlägget</xsl:variable>
	<xsl:variable name="i18n.Comments">Kommentarer</xsl:variable>
	<xsl:variable name="i18n.AddCommentPlaceHolder">Skriv en kommentar</xsl:variable>
	<xsl:variable name="i18n.Send">Skicka</xsl:variable>
	<xsl:variable name="i18n.ManagePost">Hantera inlägget</xsl:variable>
	<xsl:variable name="i18n.ManageComment">Hantera kommentaren</xsl:variable>
	<xsl:variable name="i18n.OpenToolbox">Öppna verktygslåda</xsl:variable>
	<xsl:variable name="i18n.UnFollow">Sluta följ</xsl:variable>
	<xsl:variable name="i18n.Follow">Följ</xsl:variable>
	<xsl:variable name="i18n.CopyURL">Kopiera URL</xsl:variable>
	<xsl:variable name="i18n.Update">Ändra</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	<xsl:variable name="i18n.or">eller</xsl:variable>
	
	<xsl:variable name="i18n.AttachFile">Bifoga filer</xsl:variable>
	
	<xsl:variable name="i18n.validationError.AttachedFileMissing">Någon av filerna du försökte bifoga hittades inte, försök igen.</xsl:variable>
	<xsl:variable name="i18n.validationError.RequiredField">Fältet får inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
	<xsl:variable name="i18n.ReadMore">visa mer</xsl:variable>
	<xsl:variable name="i18n.HideText">dölj text</xsl:variable>
</xsl:stylesheet>
