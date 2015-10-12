<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="CalendarModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Skapa kalenderh�ndelse</xsl:variable>

	<xsl:variable name="i18n.Title">Namnge kalenderh�ndelse</xsl:variable>
	<xsl:variable name="i18n.WholeDay">Heldag</xsl:variable>
	<xsl:variable name="i18n.Yes">Ja</xsl:variable>
	<xsl:variable name="i18n.No">Nej</xsl:variable>
	<xsl:variable name="i18n.StartDate">Datum fr�n</xsl:variable>
	<xsl:variable name="i18n.EndDate">Datum till</xsl:variable>
	<xsl:variable name="i18n.StartTime">Tid fr�n</xsl:variable>
	<xsl:variable name="i18n.EndTime">Tid till</xsl:variable>
	<xsl:variable name="i18n.Description">Beskrivning</xsl:variable>
	<xsl:variable name="i18n.Add">L�gg till</xsl:variable>
	<xsl:variable name="i18n.DeletedUser">Borttagen anv�ndare</xsl:variable>
	<xsl:variable name="i18n.NewPost">Ny kalenderh�ndelse</xsl:variable>
	<xsl:variable name="i18n.Location">Plats</xsl:variable>

	<xsl:variable name="i18n.PreviousMonth">F�reg�ende m�nad</xsl:variable>
	<xsl:variable name="i18n.Agenda">Agenda</xsl:variable>
	<xsl:variable name="i18n.Month">M�nad</xsl:variable>
	<xsl:variable name="i18n.NextMonth">N�sta m�nad</xsl:variable>
	<xsl:variable name="i18n.Back">Tillbaka</xsl:variable>
	<xsl:variable name="i18n.Update">�ndra</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.or">eller</xsl:variable>
	<xsl:variable name="i18n.DeletePostConfirm">�r du s�ker p� att du vill ta bort kalenderh�ndelsen</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.Starts">B�rjar</xsl:variable>
	<xsl:variable name="i18n.Ends">Slutar</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">�ndrad av</xsl:variable>
	<xsl:variable name="i18n.MorePosts">Fler aktiviteter</xsl:variable>
	<xsl:variable name="i18n.ShowMore">Visa fler</xsl:variable>
	<xsl:variable name="i18n.AllSections">Alla rum</xsl:variable>

	<xsl:variable name="i18n.NoPosts">Det finns inga kommande kalenderh�ndelser</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Du m�ste fylla i f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">F�r l�ngt v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">F�r kort v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett ok�nt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett ok�nt fel har uppst�tt</xsl:variable>
	
	<xsl:variable name="i18n.validationError.DaysBetweenToSmall">Slutdatum kan inte ligga f�re startdatum</xsl:variable>
	<xsl:variable name="i18n.validationError.EndTimeBeforeStartTime">Sluttid kan inte ligga f�re starttid</xsl:variable>
	
	<xsl:variable name="i18n.SubscribeToCalendar">Prenumerera p� denna kalender</xsl:variable>
</xsl:stylesheet>
