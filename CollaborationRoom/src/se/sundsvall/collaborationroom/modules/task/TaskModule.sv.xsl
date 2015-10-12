<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="TaskModuleTemplates.xsl"/>
	<xsl:include href="TasksModuleCommon.sv.xsl"/>

	<xsl:variable name="java.shortCutText">Skapa uppgiftslista</xsl:variable>

	<xsl:variable name="i18n.NoTaskLists">Det finns inga pågående uppgiftslistor. För att kunna skapa en uppgift behöver du först skapa en uppgiftslista, klicka på knappen Ny uppgiftslista.</xsl:variable>
	
	<xsl:variable name="i18n.NewTaskList">Ny uppgiftslista</xsl:variable>
	<xsl:variable name="i18n.NewTask">Ny uppgift</xsl:variable>
	<xsl:variable name="i18n.TaskListName">Namnge uppgiftslistan</xsl:variable>
	<xsl:variable name="i18n.TaskList">Uppgiftslista</xsl:variable>
	<xsl:variable name="i18n.Add">Lägg till</xsl:variable>
	<xsl:variable name="i18n.Update">Ändra</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	<xsl:variable name="i18n.NoTasks">Inga uppgifter</xsl:variable>
	<xsl:variable name="i18n.NotAssigned">Ej tilldelad</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">Ändrad av</xsl:variable>
	<xsl:variable name="i18n.FinishedTaskLists">Avklarade uppgiftslistor</xsl:variable>
	<xsl:variable name="i18n.ShowFinished.Part1">Visa</xsl:variable>
	<xsl:variable name="i18n.ShowFinished.Part2">avklarade uppgifter</xsl:variable>
	
	<xsl:variable name="i18n.Close">Stäng</xsl:variable>
	<xsl:variable name="i18n.Task">Uppgift</xsl:variable>
	<xsl:variable name="i18n.Description">Beskrivning</xsl:variable>
	<xsl:variable name="i18n.Optional">Frivilligt</xsl:variable>
	<xsl:variable name="i18n.ChooseResponsible">Välj ansvarig</xsl:variable>
	<xsl:variable name="i18n.Deadline">Deadline</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.Cancel">Avbryt</xsl:variable>

	<xsl:variable name="i18n.FinishedBy">Färdigställd av</xsl:variable>
	<xsl:variable name="i18n.DeleteTaskConfirm">Är du säker på att du vill ta bort uppgiften</xsl:variable>
	<xsl:variable name="i18n.DeleteTaskListConfirm">Är du säker på att du vill ta bort uppgiftslistan</xsl:variable>
	
	<xsl:variable name="i18n.FinishTaskError">Du har inte rättighet att klarmarkera den här uppgiften eftersom den är tilldelad till</xsl:variable>
	<xsl:variable name="i18n.Back">Tillbaka</xsl:variable>
	<xsl:variable name="i18n.AllMembers">Alla ansvariga...</xsl:variable>

	<xsl:variable name="i18n.MarkAsFinished">Markera uppgiften som klar</xsl:variable>
	<xsl:variable name="i18n.MarkAsNotFinished">Markera uppgiften som ej klar</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Fältet får inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
	
	<xsl:variable name="i18n.IncludeFinished">Alla inklusive avklarade</xsl:variable>
	<xsl:variable name="i18n.Finished">Avklarad</xsl:variable>
	<xsl:variable name="i18n.FinishedMultiple">Avklarade</xsl:variable>
	<xsl:variable name="i18n.Status">Status</xsl:variable>
	<xsl:variable name="i18n.Active">Ogjord</xsl:variable>
	<xsl:variable name="i18n.ActiveMultiple">Ogjorda</xsl:variable>
	<xsl:variable name="i18n.NearDeadline">Håller på att missa deadline</xsl:variable>
	<xsl:variable name="i18n.MissedDeadline">Missat deadline</xsl:variable>
	<xsl:variable name="i18n.ThisWeek">Denna vecka</xsl:variable>
	<xsl:variable name="i18n.NextWeek">Nästa vecka</xsl:variable>
	<xsl:variable name="i18n.TaskListNotFound">Den valda uppgiftslistan hittades inte</xsl:variable>
	
	<xsl:variable name="i18n.SortOnTaskList">Alla uppgiftslistor...</xsl:variable>
	<xsl:variable name="i18n.HiddenTaskListsPre">Det finns ytterligare</xsl:variable>
	<xsl:variable name="i18n.HiddenTaskListsPost">uppgiftslistor som inte visas med aktuellt filter</xsl:variable>
	<xsl:variable name="i18n.HiddenTaskTablePre">Det finns ytterligare</xsl:variable>
	<xsl:variable name="i18n.HiddenTaskTablePost">uppgifter som inte visas med aktuellt filter</xsl:variable>
	
	<xsl:variable name="i18n.ListTitle">Visa som lista</xsl:variable>
	<xsl:variable name="i18n.TableTitle">Visa som tabell</xsl:variable>

<xsl:variable name="i18n.ResponsibleUser">Ansvarig</xsl:variable>
<xsl:variable name="i18n.ExcludeFinished">Alla statusar utom avklarade</xsl:variable>
</xsl:stylesheet>
