<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="MembersModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Bjud in deltagare</xsl:variable>

	<xsl:variable name="i18n.DeletedUser">Borttagen användare</xsl:variable>

	<xsl:variable name="i18n.InviteUsers">Bjud in deltagare</xsl:variable>
	<xsl:variable name="i18n.AllMembers">Alla deltagare</xsl:variable>
	<xsl:variable name="i18n.NoMembers">Inga deltagare</xsl:variable>
	<xsl:variable name="i18n.InvitedUsers">Inbjudna</xsl:variable>
	<xsl:variable name="i18n.NoInvitedUsers">Inga inbjudna deltagare</xsl:variable>
	<xsl:variable name="i18n.DeleteFromRoom.Part1">Ta bort</xsl:variable>
	<xsl:variable name="i18n.DeleteFromRoom.Part2">från samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.DeleteMemberConfirm.Part1">Är du säker på att du vill ta bort deltagaren</xsl:variable>
	<xsl:variable name="i18n.DeleteMemberConfirm.Part2">från samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.DeleteYourselfConfirm">Är du säker på att du vill ta bort dig själv från samarbetsrummet</xsl:variable>
	
	<xsl:variable name="i18n.NewRoleMessage">Ny roll satt till</xsl:variable>
	<xsl:variable name="i18n.MemberDeletedMessage">borttagen från samarbetsrummet</xsl:variable>

	<xsl:variable name="i18n.InviteInternalUsers">Bjud in medarbetare</xsl:variable>
	<xsl:variable name="i18n.SearchByName">Sök på namn för att hitta medarbetare</xsl:variable>
	<xsl:variable name="i18n.DeleteFormList.Part1">Ta bort</xsl:variable>
	<xsl:variable name="i18n.DeleteFormList.Part2">från listan</xsl:variable>
	<xsl:variable name="i18n.Add">Lägg till</xsl:variable>
	<xsl:variable name="i18n.InternalUsers">Medarbetare</xsl:variable>
	<xsl:variable name="i18n.ExternalUsers">Extern</xsl:variable>
	<xsl:variable name="i18n.Group">Grupp</xsl:variable>

	<xsl:variable name="i18n.NoUsersFound">Inga användare matchade sökningen</xsl:variable>
	<xsl:variable name="i18n.NoUsersFoundExternalHint">Om du vill bjuda in en extern deltagare, använd fliken "Extern"</xsl:variable>
	<xsl:variable name="i18n.InviteExternalUser">Bjud in externa deltagare </xsl:variable>
	<xsl:variable name="i18n.InviteByEmail">Ange e-postadress, separarera med komma för att bjuda in flera deltagare samtidigt. Tryck retur för att lägga till.</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>

	<xsl:variable name="i18n.ExistingUserMessage">har redan ett användarkonto med den här e-postadressen och kommer att få åtkomst till samarbetsrummet direkt.</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleMessage.Part1">har redan rollen</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleMessage.Part2">i det här samarbetsrummet. Inbjudan kommer att ignoreras.</xsl:variable>
	<xsl:variable name="i18n.ExistingInvitationMessage">Det finns redan en inbjudan till ett annat samarbetsrum för den här e-postadressen. Användaren kommer få åtkomst till samarbetsrummet så snart han/hon registrerat ett konto.</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleInvitationMessage.Part1">Det finns redan en inbjudan med e-postadressen</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleInvitationMessage.Part2">i det här samarbetsrummet. Inbjudan kommer att ignoreras.</xsl:variable>

	<xsl:variable name="i18n.NoManageMemberRole">Det måste finnas minst en deltagare med rollen Administratör i samarbetsrummet!</xsl:variable>

	<xsl:variable name="i18n.InvitationResent">Inbjudan skickades om till</xsl:variable>
	<xsl:variable name="i18n.ChooseUserRole">Ändra roll för användaren</xsl:variable>
	<xsl:variable name="i18n.ChooseInvitationRole">Ändra roll för inbjudan</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">Fältet får inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	
	<xsl:variable name="i18n.DeleteInvitation.Part1">Ta bort inbjudan för e-postadressen</xsl:variable>
	<xsl:variable name="i18n.DeleteInvitation.Part2">till det här samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.DeleteInvitationConfirm">Är du säker på att du vill ta bort inbjudan till samarbetsrummet för e-postadressen</xsl:variable>
	<xsl:variable name="i18n.InvitationLastSent">Inbjudan skickades senast</xsl:variable>
	<xsl:variable name="i18n.InvitationSentCount.Part1">Inbjudan har skickats</xsl:variable>
	<xsl:variable name="i18n.InvitationSentCount.Part2">gånger</xsl:variable>
	<xsl:variable name="i18n.ResendInvitation">Skicka om inbjudan</xsl:variable>
	
	<xsl:variable name="i18n.InviteGroup">Bjud in grupp/förvaltning</xsl:variable>
	<xsl:variable name="i18n.SearchGroupByName">Sök på förvaltning för att hitta medarbetare.</xsl:variable>
	<xsl:variable name="i18n.users">användare</xsl:variable>
	<xsl:variable name="i18n.NoGroupsFound">Inga grupper matchade sökningen</xsl:variable>
</xsl:stylesheet>
