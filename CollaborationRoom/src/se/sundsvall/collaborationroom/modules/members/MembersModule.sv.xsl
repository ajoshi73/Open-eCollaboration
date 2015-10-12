<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="MembersModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Bjud in deltagare</xsl:variable>

	<xsl:variable name="i18n.DeletedUser">Borttagen anv�ndare</xsl:variable>

	<xsl:variable name="i18n.InviteUsers">Bjud in deltagare</xsl:variable>
	<xsl:variable name="i18n.AllMembers">Alla deltagare</xsl:variable>
	<xsl:variable name="i18n.NoMembers">Inga deltagare</xsl:variable>
	<xsl:variable name="i18n.InvitedUsers">Inbjudna</xsl:variable>
	<xsl:variable name="i18n.NoInvitedUsers">Inga inbjudna deltagare</xsl:variable>
	<xsl:variable name="i18n.DeleteFromRoom.Part1">Ta bort</xsl:variable>
	<xsl:variable name="i18n.DeleteFromRoom.Part2">fr�n samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.DeleteMemberConfirm.Part1">�r du s�ker p� att du vill ta bort deltagaren</xsl:variable>
	<xsl:variable name="i18n.DeleteMemberConfirm.Part2">fr�n samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.DeleteYourselfConfirm">�r du s�ker p� att du vill ta bort dig sj�lv fr�n samarbetsrummet</xsl:variable>
	
	<xsl:variable name="i18n.NewRoleMessage">Ny roll satt till</xsl:variable>
	<xsl:variable name="i18n.MemberDeletedMessage">borttagen fr�n samarbetsrummet</xsl:variable>

	<xsl:variable name="i18n.InviteInternalUsers">Bjud in medarbetare</xsl:variable>
	<xsl:variable name="i18n.SearchByName">S�k p� namn f�r att hitta medarbetare</xsl:variable>
	<xsl:variable name="i18n.DeleteFormList.Part1">Ta bort</xsl:variable>
	<xsl:variable name="i18n.DeleteFormList.Part2">fr�n listan</xsl:variable>
	<xsl:variable name="i18n.Add">L�gg till</xsl:variable>
	<xsl:variable name="i18n.InternalUsers">Medarbetare</xsl:variable>
	<xsl:variable name="i18n.ExternalUsers">Extern</xsl:variable>
	<xsl:variable name="i18n.Group">Grupp</xsl:variable>

	<xsl:variable name="i18n.NoUsersFound">Inga anv�ndare matchade s�kningen</xsl:variable>
	<xsl:variable name="i18n.NoUsersFoundExternalHint">Om du vill bjuda in en extern deltagare, anv�nd fliken "Extern"</xsl:variable>
	<xsl:variable name="i18n.InviteExternalUser">Bjud in externa deltagare </xsl:variable>
	<xsl:variable name="i18n.InviteByEmail">Ange e-postadress, separarera med komma f�r att bjuda in flera deltagare samtidigt. Tryck retur f�r att l�gga till.</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>

	<xsl:variable name="i18n.ExistingUserMessage">har redan ett anv�ndarkonto med den h�r e-postadressen och kommer att f� �tkomst till samarbetsrummet direkt.</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleMessage.Part1">har redan rollen</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleMessage.Part2">i det h�r samarbetsrummet. Inbjudan kommer att ignoreras.</xsl:variable>
	<xsl:variable name="i18n.ExistingInvitationMessage">Det finns redan en inbjudan till ett annat samarbetsrum f�r den h�r e-postadressen. Anv�ndaren kommer f� �tkomst till samarbetsrummet s� snart han/hon registrerat ett konto.</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleInvitationMessage.Part1">Det finns redan en inbjudan med e-postadressen</xsl:variable>
	<xsl:variable name="i18n.ExistingRoleInvitationMessage.Part2">i det h�r samarbetsrummet. Inbjudan kommer att ignoreras.</xsl:variable>

	<xsl:variable name="i18n.NoManageMemberRole">Det m�ste finnas minst en deltagare med rollen Administrat�r i samarbetsrummet!</xsl:variable>

	<xsl:variable name="i18n.InvitationResent">Inbjudan skickades om till</xsl:variable>
	<xsl:variable name="i18n.ChooseUserRole">�ndra roll f�r anv�ndaren</xsl:variable>
	<xsl:variable name="i18n.ChooseInvitationRole">�ndra roll f�r inbjudan</xsl:variable>

	<xsl:variable name="i18n.validationError.RequiredField">F�ltet f�r inte vara tomt</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">F�r l�ngt v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">F�r kort v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett ok�nt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett ok�nt fel har uppst�tt</xsl:variable>
	
	<xsl:variable name="i18n.DeleteInvitation.Part1">Ta bort inbjudan f�r e-postadressen</xsl:variable>
	<xsl:variable name="i18n.DeleteInvitation.Part2">till det h�r samarbetsrummet</xsl:variable>
	<xsl:variable name="i18n.DeleteInvitationConfirm">�r du s�ker p� att du vill ta bort inbjudan till samarbetsrummet f�r e-postadressen</xsl:variable>
	<xsl:variable name="i18n.InvitationLastSent">Inbjudan skickades senast</xsl:variable>
	<xsl:variable name="i18n.InvitationSentCount.Part1">Inbjudan har skickats</xsl:variable>
	<xsl:variable name="i18n.InvitationSentCount.Part2">g�nger</xsl:variable>
	<xsl:variable name="i18n.ResendInvitation">Skicka om inbjudan</xsl:variable>
	
	<xsl:variable name="i18n.InviteGroup">Bjud in grupp/f�rvaltning</xsl:variable>
	<xsl:variable name="i18n.SearchGroupByName">S�k p� f�rvaltning f�r att hitta medarbetare.</xsl:variable>
	<xsl:variable name="i18n.users">anv�ndare</xsl:variable>
	<xsl:variable name="i18n.NoGroupsFound">Inga grupper matchade s�kningen</xsl:variable>
</xsl:stylesheet>
