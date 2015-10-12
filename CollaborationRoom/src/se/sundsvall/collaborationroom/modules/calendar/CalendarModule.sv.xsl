<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="CalendarModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Skapa kalenderhändelse</xsl:variable>

	<xsl:variable name="i18n.Title">Namnge kalenderhändelse</xsl:variable>
	<xsl:variable name="i18n.WholeDay">Heldag</xsl:variable>
	<xsl:variable name="i18n.Yes">Ja</xsl:variable>
	<xsl:variable name="i18n.No">Nej</xsl:variable>
	<xsl:variable name="i18n.StartDate">Datum från</xsl:variable>
	<xsl:variable name="i18n.EndDate">Datum till</xsl:variable>
	<xsl:variable name="i18n.StartTime">Tid från</xsl:variable>
	<xsl:variable name="i18n.EndTime">Tid till</xsl:variable>
	<xsl:variable name="i18n.Description">Beskrivning</xsl:variable>
	<xsl:variable name="i18n.Add">Lägg till</xsl:variable>
	<xsl:variable name="i18n.DeletedUser">Borttagen användare</xsl:variable>
	<xsl:variable name="i18n.NewPost">Ny kalenderhändelse</xsl:variable>
	<xsl:variable name="i18n.Location">Plats</xsl:variable>

	<xsl:variable name="i18n.PreviousMonth">Föregående månad</xsl:variable>
	<xsl:variable name="i18n.Agenda">Agenda</xsl:variable>
	<xsl:variable name="i18n.Month">Månad</xsl:variable>
	<xsl:variable name="i18n.NextMonth">Nästa månad</xsl:variable>
	<xsl:variable name="i18n.Back">Tillbaka</xsl:variable>
	<xsl:variable name="i18n.Update">Ändra</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.or">eller</xsl:variable>
	<xsl:variable name="i18n.DeletePostConfirm">Är du säker på att du vill ta bort kalenderhändelsen</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.Starts">Börjar</xsl:variable>
	<xsl:variable name="i18n.Ends">Slutar</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">Ändrad av</xsl:variable>
	<xsl:variable name="i18n.MorePosts">Fler aktiviteter</xsl:variable>
	<xsl:variable name="i18n.ShowMore">Visa fler</xsl:variable>
	<xsl:variable name="i18n.AllSections">Alla rum</xsl:variable>

	<xsl:variable name="i18n.NoPosts">Det finns inga kommande kalenderhändelser</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Du måste fylla i fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
	<xsl:variable name="i18n.validationError.DaysBetweenToSmall">Slutdatum kan inte ligga före startdatum</xsl:variable>
	<xsl:variable name="i18n.validationError.EndTimeBeforeStartTime">Sluttid kan inte ligga före starttid</xsl:variable>
	
	<xsl:variable name="i18n.SubscribeToCalendar">Prenumerera på denna kalender</xsl:variable>
</xsl:stylesheet>
