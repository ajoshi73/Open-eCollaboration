<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="FileArchiveModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Ladda upp fil</xsl:variable>
	<xsl:variable name="java.autoCreatedCategoryName">Övrigt</xsl:variable>
	
	<xsl:variable name="i18n.NewCategory">Ny kategori</xsl:variable>
	<xsl:variable name="i18n.CategoryName">Namnge kategorin</xsl:variable>
	<xsl:variable name="i18n.Category">Kategori</xsl:variable>
	<xsl:variable name="i18n.Add">Lägg till</xsl:variable>
	<xsl:variable name="i18n.Update">Ändra</xsl:variable>
	<xsl:variable name="i18n.DeleteCategoryConfirm">Är du säker på att du vill ta bort kategorin</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	<xsl:variable name="i18n.NoFiles">Det finns inga filer i den här kategorin</xsl:variable>
	<xsl:variable name="i18n.NoFilesOrCategories">Inga kategorier eller filer</xsl:variable>
	<xsl:variable name="i18n.DeleteFileConfirm">Är du säker på att du vill ta bort filen</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">Ändrad av</xsl:variable>
	<xsl:variable name="i18n.Close">Stäng</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.Cancel">Avbryt</xsl:variable>
	<xsl:variable name="i18n.HandleFile">Hantera filen</xsl:variable>
	<xsl:variable name="i18n.HandleCategory">Hantera kategorin</xsl:variable>
	<xsl:variable name="i18n.OpenToolbox">Öppna verktygslåda</xsl:variable>
	<xsl:variable name="i18n.UnLockFile">Lås upp filen</xsl:variable>
	<xsl:variable name="i18n.LockFile">Lås filen</xsl:variable>
	<xsl:variable name="i18n.MaxFileSize">Filer får vara maximalt</xsl:variable>
	<xsl:variable name="i18n.Tags">Taggar</xsl:variable>
	<xsl:variable name="i18n.LockedBy">Låst av</xsl:variable>
	<xsl:variable name="i18n.until">t.o.m</xsl:variable>
	<xsl:variable name="i18n.ReplaceFile">Ersätt fil</xsl:variable>
	<xsl:variable name="i18n.ChooseFile">Välj fil</xsl:variable>
	<xsl:variable name="i18n.Replace">Ersätt</xsl:variable>
	
	<xsl:variable name="i18n.InvalidFileType">Den här filen har en otillåten filtyp och har därmed ignorerats.</xsl:variable>
	<xsl:variable name="i18n.InvalidFileFormat">Filen har en otillåten filtyp.</xsl:variable>
	<xsl:variable name="i18n.AllowedFileTypes">Tillåtna filtyper är</xsl:variable>
	<xsl:variable name="i18n.FileSizeToBig">Den här filen är för stor och har därmed ignorerats.</xsl:variable>
	<xsl:variable name="i18n.TagFile">Tagga filen</xsl:variable>

	<xsl:variable name="i18n.UnableToParseFile">Ett fel inträffade då den här filen laddades upp, försök igen.</xsl:variable>
	<xsl:variable name="i18n.FileSizeLimitExceeded">Filen är för stor.</xsl:variable>
	<xsl:variable name="i18n.NoFileAttached">Du måste välja en fil.</xsl:variable>
	
	<xsl:variable name="i18n.SortOn">Sortera filer på...</xsl:variable>
	<xsl:variable name="i18n.Filename">Namn</xsl:variable>
	<xsl:variable name="i18n.LastCreated">Senast skapad</xsl:variable>
	<xsl:variable name="i18n.LastUpdated">Senast ändrad</xsl:variable>
	<xsl:variable name="i18n.Size">Storlek</xsl:variable>
	
	<xsl:variable name="i18n.FilterByName">Filtrera genom att söka på namn</xsl:variable>
	
	<xsl:variable name="i18n.AttachFiles">Bifoga filer</xsl:variable>
	<xsl:variable name="i18n.AttachMarkedFiles">Bifoga markerade filer</xsl:variable>
	<xsl:variable name="i18n.MarkedFilesCount.Singular">markerad fil</xsl:variable>
	<xsl:variable name="i18n.MarkedFilesCount.Plural">markerade filer</xsl:variable>
	
	<xsl:variable name="i18n.AttachFilesDescription">Markera de filer som du vill bifoga och klicka på knappen "Bifoga markerade filer"</xsl:variable>
	
	<xsl:variable name="i18n.validationError.RequiredField">Du måste fylla i fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">För långt värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">För kort värde på fältet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett okänt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett okänt fel har uppstått</xsl:variable>
	<xsl:variable name="i18n.DeletedUser">Borttagen användare</xsl:variable>
	
	<xsl:variable name="i18n.SortOnCategory">Filtrera kategori...</xsl:variable>
	<xsl:variable name="i18n.HiddenCategoriesPre">Det finns ytterligare</xsl:variable>
	<xsl:variable name="i18n.HiddenCategoriesPost">kategorier som inte visas med aktuellt filter</xsl:variable>
	<xsl:variable name="i18n.AddFileHelp">Släpp nya filer här eller klicka på "Ny fil"</xsl:variable>
	
	<xsl:variable name="i18n.NewFile">Ny fil</xsl:variable>
	
	<xsl:variable name="i18n.EmailHelpTitle">Skicka in filer som e-post</xsl:variable>
	
</xsl:stylesheet>
