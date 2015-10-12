<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="ISO-8859-1" method="html" version="4.0"/>
	
	<xsl:include href="FileArchiveModuleTemplates.xsl"/>

	<xsl:variable name="java.shortCutText">Ladda upp fil</xsl:variable>
	<xsl:variable name="java.autoCreatedCategoryName">�vrigt</xsl:variable>
	
	<xsl:variable name="i18n.NewCategory">Ny kategori</xsl:variable>
	<xsl:variable name="i18n.CategoryName">Namnge kategorin</xsl:variable>
	<xsl:variable name="i18n.Category">Kategori</xsl:variable>
	<xsl:variable name="i18n.Add">L�gg till</xsl:variable>
	<xsl:variable name="i18n.Update">�ndra</xsl:variable>
	<xsl:variable name="i18n.DeleteCategoryConfirm">�r du s�ker p� att du vill ta bort kategorin</xsl:variable>
	<xsl:variable name="i18n.Delete">Ta bort</xsl:variable>
	<xsl:variable name="i18n.NoFiles">Det finns inga filer i den h�r kategorin</xsl:variable>
	<xsl:variable name="i18n.NoFilesOrCategories">Inga kategorier eller filer</xsl:variable>
	<xsl:variable name="i18n.DeleteFileConfirm">�r du s�ker p� att du vill ta bort filen</xsl:variable>
	<xsl:variable name="i18n.AddedBy">Skapad av</xsl:variable>
	<xsl:variable name="i18n.UpdatedBy">�ndrad av</xsl:variable>
	<xsl:variable name="i18n.Close">St�ng</xsl:variable>
	<xsl:variable name="i18n.Save">Spara</xsl:variable>
	<xsl:variable name="i18n.Cancel">Avbryt</xsl:variable>
	<xsl:variable name="i18n.HandleFile">Hantera filen</xsl:variable>
	<xsl:variable name="i18n.HandleCategory">Hantera kategorin</xsl:variable>
	<xsl:variable name="i18n.OpenToolbox">�ppna verktygsl�da</xsl:variable>
	<xsl:variable name="i18n.UnLockFile">L�s upp filen</xsl:variable>
	<xsl:variable name="i18n.LockFile">L�s filen</xsl:variable>
	<xsl:variable name="i18n.MaxFileSize">Filer f�r vara maximalt</xsl:variable>
	<xsl:variable name="i18n.Tags">Taggar</xsl:variable>
	<xsl:variable name="i18n.LockedBy">L�st av</xsl:variable>
	<xsl:variable name="i18n.until">t.o.m</xsl:variable>
	<xsl:variable name="i18n.ReplaceFile">Ers�tt fil</xsl:variable>
	<xsl:variable name="i18n.ChooseFile">V�lj fil</xsl:variable>
	<xsl:variable name="i18n.Replace">Ers�tt</xsl:variable>
	
	<xsl:variable name="i18n.InvalidFileType">Den h�r filen har en otill�ten filtyp och har d�rmed ignorerats.</xsl:variable>
	<xsl:variable name="i18n.InvalidFileFormat">Filen har en otill�ten filtyp.</xsl:variable>
	<xsl:variable name="i18n.AllowedFileTypes">Till�tna filtyper �r</xsl:variable>
	<xsl:variable name="i18n.FileSizeToBig">Den h�r filen �r f�r stor och har d�rmed ignorerats.</xsl:variable>
	<xsl:variable name="i18n.TagFile">Tagga filen</xsl:variable>

	<xsl:variable name="i18n.UnableToParseFile">Ett fel intr�ffade d� den h�r filen laddades upp, f�rs�k igen.</xsl:variable>
	<xsl:variable name="i18n.FileSizeLimitExceeded">Filen �r f�r stor.</xsl:variable>
	<xsl:variable name="i18n.NoFileAttached">Du m�ste v�lja en fil.</xsl:variable>
	
	<xsl:variable name="i18n.SortOn">Sortera filer p�...</xsl:variable>
	<xsl:variable name="i18n.Filename">Namn</xsl:variable>
	<xsl:variable name="i18n.LastCreated">Senast skapad</xsl:variable>
	<xsl:variable name="i18n.LastUpdated">Senast �ndrad</xsl:variable>
	<xsl:variable name="i18n.Size">Storlek</xsl:variable>
	
	<xsl:variable name="i18n.FilterByName">Filtrera genom att s�ka p� namn</xsl:variable>
	
	<xsl:variable name="i18n.AttachFiles">Bifoga filer</xsl:variable>
	<xsl:variable name="i18n.AttachMarkedFiles">Bifoga markerade filer</xsl:variable>
	<xsl:variable name="i18n.MarkedFilesCount.Singular">markerad fil</xsl:variable>
	<xsl:variable name="i18n.MarkedFilesCount.Plural">markerade filer</xsl:variable>
	
	<xsl:variable name="i18n.AttachFilesDescription">Markera de filer som du vill bifoga och klicka p� knappen "Bifoga markerade filer"</xsl:variable>
	
	<xsl:variable name="i18n.validationError.RequiredField">Du m�ste fylla i f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.InvalidFormat">Felaktigt format p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooLong">F�r l�ngt v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.TooShort">F�r kort v�rde p� f�ltet</xsl:variable>
	<xsl:variable name="i18n.validationError.Other">Ett ok�nt fel</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownValidationErrorType">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.validationError.unknownMessageKey">Ett ok�nt fel har uppst�tt</xsl:variable>
	<xsl:variable name="i18n.DeletedUser">Borttagen anv�ndare</xsl:variable>
	
	<xsl:variable name="i18n.SortOnCategory">Filtrera kategori...</xsl:variable>
	<xsl:variable name="i18n.HiddenCategoriesPre">Det finns ytterligare</xsl:variable>
	<xsl:variable name="i18n.HiddenCategoriesPost">kategorier som inte visas med aktuellt filter</xsl:variable>
	<xsl:variable name="i18n.AddFileHelp">Sl�pp nya filer h�r eller klicka p� "Ny fil"</xsl:variable>
	
	<xsl:variable name="i18n.NewFile">Ny fil</xsl:variable>
	
	<xsl:variable name="i18n.EmailHelpTitle">Skicka in filer som e-post</xsl:variable>
	
</xsl:stylesheet>
