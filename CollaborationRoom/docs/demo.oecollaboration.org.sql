-- MySQL dump 10.13  Distrib 5.1.73, for Win64 (unknown)
--
-- Host: localhost    Database: demo.oecollaboration.org
-- ------------------------------------------------------
-- Server version	5.1.73-community

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `communitybase_blog_post_comments`
--

DROP TABLE IF EXISTS `communitybase_blog_post_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_blog_post_comments` (
  `commentID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `message` mediumtext NOT NULL,
  `postID` int(10) unsigned NOT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`commentID`),
  KEY `FK_communitybase_blog_post_comments_1` (`postID`),
  CONSTRAINT `FK_communitybase_blog_post_comments_1` FOREIGN KEY (`postID`) REFERENCES `communitybase_blog_posts` (`postID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_blog_post_comments`
--

LOCK TABLES `communitybase_blog_post_comments` WRITE;
/*!40000 ALTER TABLE `communitybase_blog_post_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_blog_post_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_blog_post_followers`
--

DROP TABLE IF EXISTS `communitybase_blog_post_followers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_blog_post_followers` (
  `postID` int(10) unsigned NOT NULL,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`postID`,`userID`),
  CONSTRAINT `FK_communitybase_blog_post_followers_1` FOREIGN KEY (`postID`) REFERENCES `communitybase_blog_posts` (`postID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_blog_post_followers`
--

LOCK TABLES `communitybase_blog_post_followers` WRITE;
/*!40000 ALTER TABLE `communitybase_blog_post_followers` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_blog_post_followers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_blog_post_linked_files`
--

DROP TABLE IF EXISTS `communitybase_blog_post_linked_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_blog_post_linked_files` (
  `postID` int(10) unsigned NOT NULL,
  `fileID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`postID`,`fileID`),
  KEY `FK_communitybase_blog_post_linked_files_1` (`fileID`),
  CONSTRAINT `FK_communitybase_blog_post_linked_files_1` FOREIGN KEY (`fileID`) REFERENCES `communitybase_file_archive_files` (`fileID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_blog_post_linked_files`
--

LOCK TABLES `communitybase_blog_post_linked_files` WRITE;
/*!40000 ALTER TABLE `communitybase_blog_post_linked_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_blog_post_linked_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_blog_post_tags`
--

DROP TABLE IF EXISTS `communitybase_blog_post_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_blog_post_tags` (
  `postID` int(10) unsigned NOT NULL,
  `tag` varchar(255) NOT NULL,
  PRIMARY KEY (`postID`,`tag`),
  CONSTRAINT `FK_communitybase_blog_post_tags_1` FOREIGN KEY (`postID`) REFERENCES `communitybase_blog_posts` (`postID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_blog_post_tags`
--

LOCK TABLES `communitybase_blog_post_tags` WRITE;
/*!40000 ALTER TABLE `communitybase_blog_post_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_blog_post_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_blog_posts`
--

DROP TABLE IF EXISTS `communitybase_blog_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_blog_posts` (
  `postID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` mediumtext NOT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`postID`),
  KEY `FK_communitybase_blog_posts_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_blog_posts_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=349 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_blog_posts`
--

LOCK TABLES `communitybase_blog_posts` WRITE;
/*!40000 ALTER TABLE `communitybase_blog_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_blog_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_calendar_posts`
--

DROP TABLE IF EXISTS `communitybase_calendar_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_calendar_posts` (
  `postID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` mediumtext,
  `location` varchar(255) DEFAULT NULL,
  `wholeDay` tinyint(1) unsigned NOT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`postID`),
  KEY `FK_communitybase_calendar_posts_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_calendar_posts_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_calendar_posts`
--

LOCK TABLES `communitybase_calendar_posts` WRITE;
/*!40000 ALTER TABLE `communitybase_calendar_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_calendar_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_file_archive_categories`
--

DROP TABLE IF EXISTS `communitybase_file_archive_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_file_archive_categories` (
  `categoryID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `autoGenerated` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`categoryID`),
  KEY `FK_communitybase_file_archive_categories_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_file_archive_categories_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=243 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_file_archive_categories`
--

LOCK TABLES `communitybase_file_archive_categories` WRITE;
/*!40000 ALTER TABLE `communitybase_file_archive_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_file_archive_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_file_archive_file_tags`
--

DROP TABLE IF EXISTS `communitybase_file_archive_file_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_file_archive_file_tags` (
  `fileID` int(10) unsigned NOT NULL,
  `tag` varchar(255) NOT NULL,
  PRIMARY KEY (`fileID`,`tag`),
  CONSTRAINT `FK_communitybase_file_archive_file_tags_1` FOREIGN KEY (`fileID`) REFERENCES `communitybase_file_archive_files` (`fileID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_file_archive_file_tags`
--

LOCK TABLES `communitybase_file_archive_file_tags` WRITE;
/*!40000 ALTER TABLE `communitybase_file_archive_file_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_file_archive_file_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_file_archive_files`
--

DROP TABLE IF EXISTS `communitybase_file_archive_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_file_archive_files` (
  `fileID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `categoryID` int(10) unsigned NOT NULL,
  `filename` varchar(255) NOT NULL,
  `size` int(10) unsigned DEFAULT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  `lockedBy` int(10) unsigned DEFAULT NULL,
  `locked` datetime DEFAULT NULL,
  PRIMARY KEY (`fileID`),
  KEY `FK_communitybase_file_archive_files_1` (`categoryID`),
  CONSTRAINT `FK_communitybase_file_archive_files_1` FOREIGN KEY (`categoryID`) REFERENCES `communitybase_file_archive_categories` (`categoryID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=399 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_file_archive_files`
--

LOCK TABLES `communitybase_file_archive_files` WRITE;
/*!40000 ALTER TABLE `communitybase_file_archive_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_file_archive_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_invitatation_section_invitations`
--

DROP TABLE IF EXISTS `communitybase_invitatation_section_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_invitatation_section_invitations` (
  `sectionID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `invitationID` int(10) unsigned NOT NULL,
  `roleID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sectionID`,`invitationID`),
  KEY `FK_communitybase_invitatation_section_invitations_1` (`invitationID`),
  CONSTRAINT `FK_communitybase_invitatation_section_invitations_1` FOREIGN KEY (`invitationID`) REFERENCES `communitybase_invitation_invitations` (`invitationID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=230 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_invitatation_section_invitations`
--

LOCK TABLES `communitybase_invitatation_section_invitations` WRITE;
/*!40000 ALTER TABLE `communitybase_invitatation_section_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_invitatation_section_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_invitation_invitations`
--

DROP TABLE IF EXISTS `communitybase_invitation_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_invitation_invitations` (
  `invitationID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `linkID` varchar(36) NOT NULL,
  `sendCount` int(10) unsigned NOT NULL,
  `lastSent` datetime DEFAULT NULL,
  PRIMARY KEY (`invitationID`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_invitation_invitations`
--

LOCK TABLES `communitybase_invitation_invitations` WRITE;
/*!40000 ALTER TABLE `communitybase_invitation_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_invitation_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_link_archive_links`
--

DROP TABLE IF EXISTS `communitybase_link_archive_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_link_archive_links` (
  `linkID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` text NOT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`linkID`),
  KEY `FK_communitybase_link_archive_links_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_link_archive_links_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_link_archive_links`
--

LOCK TABLES `communitybase_link_archive_links` WRITE;
/*!40000 ALTER TABLE `communitybase_link_archive_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_link_archive_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_notification_attributes`
--

DROP TABLE IF EXISTS `communitybase_notification_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_notification_attributes` (
  `notificationID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `value` varchar(1024) NOT NULL,
  PRIMARY KEY (`notificationID`,`name`),
  CONSTRAINT `FK_communitybase_notification_attributes_1` FOREIGN KEY (`notificationID`) REFERENCES `communitybase_notifications` (`notificationID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_notification_attributes`
--

LOCK TABLES `communitybase_notification_attributes` WRITE;
/*!40000 ALTER TABLE `communitybase_notification_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_notification_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_notifications`
--

DROP TABLE IF EXISTS `communitybase_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_notifications` (
  `notificationID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned DEFAULT NULL,
  `sourceModuleID` int(10) unsigned NOT NULL,
  `userID` int(10) unsigned NOT NULL,
  `added` datetime NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `isRead` tinyint(1) NOT NULL,
  `notificationType` varchar(255) DEFAULT NULL,
  `externalNotificationID` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`notificationID`),
  KEY `FK_communitybase_notifications_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_notifications_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_notifications`
--

LOCK TABLES `communitybase_notifications` WRITE;
/*!40000 ALTER TABLE `communitybase_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_page_pages`
--

DROP TABLE IF EXISTS `communitybase_page_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_page_pages` (
  `pageID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` mediumtext,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`pageID`),
  KEY `FK_communitybase_page_pages_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_page_pages_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_page_pages`
--

LOCK TABLES `communitybase_page_pages` WRITE;
/*!40000 ALTER TABLE `communitybase_page_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_page_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_prefered_sections`
--

DROP TABLE IF EXISTS `communitybase_prefered_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_prefered_sections` (
  `userID` int(10) unsigned NOT NULL,
  `sectionID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`userID`,`sectionID`),
  KEY `FK_communitybase_prefered_sections_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_prefered_sections_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_prefered_sections`
--

LOCK TABLES `communitybase_prefered_sections` WRITE;
/*!40000 ALTER TABLE `communitybase_prefered_sections` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_prefered_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_roles`
--

DROP TABLE IF EXISTS `communitybase_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_roles` (
  `roleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `addContentAccess` tinyint(1) unsigned NOT NULL,
  `updateOwnContentAccess` tinyint(1) unsigned NOT NULL,
  `deleteOwnContentAccess` tinyint(1) unsigned NOT NULL,
  `updateOtherContentAccess` tinyint(1) unsigned NOT NULL,
  `deleteOtherContentAccess` tinyint(1) unsigned NOT NULL,
  `manageMembersAccess` tinyint(1) unsigned NOT NULL,
  `manageModulesAccess` tinyint(1) unsigned NOT NULL,
  `manageSectionAccessModeAccess` tinyint(1) unsigned NOT NULL,
  `manageArchivedAccess` tinyint(1) NOT NULL,
  `deleteRoomAccess` tinyint(1) NOT NULL,
  PRIMARY KEY (`roleID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_roles`
--

LOCK TABLES `communitybase_roles` WRITE;
/*!40000 ALTER TABLE `communitybase_roles` DISABLE KEYS */;
INSERT INTO `communitybase_roles` VALUES (1,'Adminstratör',1,1,1,1,1,1,1,1,0,1),(2,'Deltagare',1,1,0,0,0,0,0,0,0,0),(3,'Följare',0,0,0,0,0,0,0,0,0,0);
/*!40000 ALTER TABLE `communitybase_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_section_favourites`
--

DROP TABLE IF EXISTS `communitybase_section_favourites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_section_favourites` (
  `sectionID` int(10) unsigned NOT NULL,
  `userID` varchar(45) NOT NULL,
  PRIMARY KEY (`sectionID`,`userID`),
  CONSTRAINT `FK_communitybase_section_favourites_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_section_favourites`
--

LOCK TABLES `communitybase_section_favourites` WRITE;
/*!40000 ALTER TABLE `communitybase_section_favourites` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_section_favourites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_section_type_add_access_groups`
--

DROP TABLE IF EXISTS `communitybase_section_type_add_access_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_section_type_add_access_groups` (
  `sectionTypeID` int(10) unsigned NOT NULL,
  `groupID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sectionTypeID`,`groupID`),
  CONSTRAINT `FK_communitybase_section_type_add_access_groups_1` FOREIGN KEY (`sectionTypeID`) REFERENCES `communitybase_section_types` (`sectionTypeID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_section_type_add_access_groups`
--

LOCK TABLES `communitybase_section_type_add_access_groups` WRITE;
/*!40000 ALTER TABLE `communitybase_section_type_add_access_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_section_type_add_access_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_section_type_background_modules`
--

DROP TABLE IF EXISTS `communitybase_section_type_background_modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_section_type_background_modules` (
  `sectionTypeID` int(10) unsigned NOT NULL,
  `moduleID` int(10) unsigned NOT NULL,
  `autoEnable` tinyint(1) NOT NULL,
  `managementMode` varchar(45) NOT NULL,
  `accessMode` varchar(45) NOT NULL,
  PRIMARY KEY (`sectionTypeID`,`moduleID`),
  KEY `FK_communitybase_section_type_background_modules_2` (`moduleID`),
  CONSTRAINT `FK_communitybase_section_type_background_modules_1` FOREIGN KEY (`sectionTypeID`) REFERENCES `communitybase_section_types` (`sectionTypeID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_communitybase_section_type_background_modules_2` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_section_type_background_modules`
--

LOCK TABLES `communitybase_section_type_background_modules` WRITE;
/*!40000 ALTER TABLE `communitybase_section_type_background_modules` DISABLE KEYS */;
INSERT INTO `communitybase_section_type_background_modules` VALUES (1,18,1,'MANAGEABLE','ALL'),(1,19,1,'HIDDEN','ALL'),(1,98,1,'MANAGEABLE','ALL'),(1,99,1,'MANAGEABLE','ALL'),(1,177,1,'MANAGEABLE','ALL'),(1,379,1,'MANAGEABLE','ALL');
/*!40000 ALTER TABLE `communitybase_section_type_background_modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_section_type_foreground_modules`
--

DROP TABLE IF EXISTS `communitybase_section_type_foreground_modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_section_type_foreground_modules` (
  `sectionTypeID` int(10) unsigned NOT NULL,
  `moduleID` int(10) unsigned NOT NULL,
  `autoEnable` tinyint(1) NOT NULL,
  `managementMode` varchar(45) NOT NULL,
  `accessMode` varchar(45) NOT NULL,
  `menuIndex` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sectionTypeID`,`moduleID`) USING BTREE,
  KEY `Index_2` (`sectionTypeID`),
  KEY `FK_communitybase_section_type_foreground_modules_2` (`moduleID`),
  CONSTRAINT `FK_communitybase_section_type_foreground_modules_1` FOREIGN KEY (`sectionTypeID`) REFERENCES `communitybase_section_types` (`sectionTypeID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_communitybase_section_type_foreground_modules_2` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_foreground_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_section_type_foreground_modules`
--

LOCK TABLES `communitybase_section_type_foreground_modules` WRITE;
/*!40000 ALTER TABLE `communitybase_section_type_foreground_modules` DISABLE KEYS */;
INSERT INTO `communitybase_section_type_foreground_modules` VALUES (1,149,1,'LOCKED','ALL',154),(1,150,1,'MANAGEABLE','ALL',153),(1,151,1,'MANAGEABLE','ALL',150),(1,152,1,'LOCKED','ADMINS',155),(1,153,1,'MANAGEABLE','ALL',152),(1,154,1,'HIDDEN','ALL',157),(1,155,1,'MANAGEABLE','ALL',156),(1,156,1,'MANAGEABLE','ALL',151),(1,157,1,'HIDDEN','ALL',149),(1,484,1,'HIDDEN','ALL',158);
/*!40000 ALTER TABLE `communitybase_section_type_foreground_modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_section_type_roles`
--

DROP TABLE IF EXISTS `communitybase_section_type_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_section_type_roles` (
  `sectionTypeID` int(10) unsigned NOT NULL,
  `roleID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sectionTypeID`,`roleID`),
  KEY `FK_communitybase_section_type_roles_2` (`roleID`),
  CONSTRAINT `FK_communitybase_section_type_roles_1` FOREIGN KEY (`sectionTypeID`) REFERENCES `communitybase_section_types` (`sectionTypeID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_communitybase_section_type_roles_2` FOREIGN KEY (`roleID`) REFERENCES `communitybase_roles` (`roleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_section_type_roles`
--

LOCK TABLES `communitybase_section_type_roles` WRITE;
/*!40000 ALTER TABLE `communitybase_section_type_roles` DISABLE KEYS */;
INSERT INTO `communitybase_section_type_roles` VALUES (1,1),(1,2),(1,3);
/*!40000 ALTER TABLE `communitybase_section_type_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_section_types`
--

DROP TABLE IF EXISTS `communitybase_section_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_section_types` (
  `sectionTypeID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `creatorRoleID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sectionTypeID`),
  KEY `FK_communitybase_section_types_1` (`creatorRoleID`),
  CONSTRAINT `FK_communitybase_section_types_1` FOREIGN KEY (`creatorRoleID`) REFERENCES `communitybase_roles` (`roleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_section_types`
--

LOCK TABLES `communitybase_section_types` WRITE;
/*!40000 ALTER TABLE `communitybase_section_types` DISABLE KEYS */;
INSERT INTO `communitybase_section_types` VALUES (1,'Samarbetsrum',1);
/*!40000 ALTER TABLE `communitybase_section_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_task_tasklists`
--

DROP TABLE IF EXISTS `communitybase_task_tasklists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_task_tasklists` (
  `taskListID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`taskListID`),
  KEY `FK_communitybase_task_tasklists_1` (`sectionID`),
  CONSTRAINT `FK_communitybase_task_tasklists_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_task_tasklists`
--

LOCK TABLES `communitybase_task_tasklists` WRITE;
/*!40000 ALTER TABLE `communitybase_task_tasklists` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_task_tasklists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communitybase_task_tasks`
--

DROP TABLE IF EXISTS `communitybase_task_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communitybase_task_tasks` (
  `taskID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `taskListID` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` mediumtext,
  `sortIndex` int(10) unsigned DEFAULT NULL,
  `responsibleUser` int(10) unsigned DEFAULT NULL,
  `deadLine` datetime DEFAULT NULL,
  `finished` datetime DEFAULT NULL,
  `finishedByUser` int(10) unsigned DEFAULT NULL,
  `posted` datetime NOT NULL,
  `poster` int(10) unsigned NOT NULL,
  `updated` datetime DEFAULT NULL,
  `editor` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`taskID`),
  KEY `FK_communitybase_task_tasks_1` (`taskListID`),
  CONSTRAINT `FK_communitybase_task_tasks_1` FOREIGN KEY (`taskListID`) REFERENCES `communitybase_task_tasklists` (`taskListID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=375 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communitybase_task_tasks`
--

LOCK TABLES `communitybase_task_tasks` WRITE;
/*!40000 ALTER TABLE `communitybase_task_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `communitybase_task_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_attachments`
--

DROP TABLE IF EXISTS `email_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_attachments` (
  `attachmenID` char(36) NOT NULL,
  `emailID` char(36) NOT NULL,
  `data` longblob NOT NULL,
  PRIMARY KEY (`attachmenID`),
  KEY `FK_attachments_1` (`emailID`),
  CONSTRAINT `FK_attachments_1` FOREIGN KEY (`emailID`) REFERENCES `emails` (`emailID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_attachments`
--

LOCK TABLES `email_attachments` WRITE;
/*!40000 ALTER TABLE `email_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_bcc_recipients`
--

DROP TABLE IF EXISTS `email_bcc_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_bcc_recipients` (
  `tableID` char(36) NOT NULL,
  `emailID` char(36) NOT NULL,
  `address` varchar(255) NOT NULL,
  PRIMARY KEY (`tableID`) USING BTREE,
  KEY `FK_bccrecipient_1` (`emailID`),
  CONSTRAINT `FK_bccrecipient_1` FOREIGN KEY (`emailID`) REFERENCES `emails` (`emailID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_bcc_recipients`
--

LOCK TABLES `email_bcc_recipients` WRITE;
/*!40000 ALTER TABLE `email_bcc_recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_bcc_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_cc_recipients`
--

DROP TABLE IF EXISTS `email_cc_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_cc_recipients` (
  `tableID` char(36) NOT NULL,
  `emailID` char(36) NOT NULL,
  `address` varchar(255) NOT NULL,
  PRIMARY KEY (`tableID`) USING BTREE,
  KEY `FK_ccrecipient_1` (`emailID`),
  CONSTRAINT `FK_ccrecipient_1` FOREIGN KEY (`emailID`) REFERENCES `emails` (`emailID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_cc_recipients`
--

LOCK TABLES `email_cc_recipients` WRITE;
/*!40000 ALTER TABLE `email_cc_recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_cc_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_recipients`
--

DROP TABLE IF EXISTS `email_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_recipients` (
  `tableID` char(36) NOT NULL,
  `emailID` char(36) NOT NULL,
  `address` varchar(255) NOT NULL,
  PRIMARY KEY (`tableID`) USING BTREE,
  KEY `FK_recipient_1` (`emailID`),
  CONSTRAINT `FK_recipient_1` FOREIGN KEY (`emailID`) REFERENCES `emails` (`emailID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_recipients`
--

LOCK TABLES `email_recipients` WRITE;
/*!40000 ALTER TABLE `email_recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_replyto`
--

DROP TABLE IF EXISTS `email_replyto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_replyto` (
  `tableID` char(36) NOT NULL,
  `emailID` char(36) NOT NULL,
  `address` varchar(255) NOT NULL,
  PRIMARY KEY (`tableID`) USING BTREE,
  KEY `FK_replyto_1` (`emailID`),
  CONSTRAINT `FK_replyto_1` FOREIGN KEY (`emailID`) REFERENCES `emails` (`emailID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_replyto`
--

LOCK TABLES `email_replyto` WRITE;
/*!40000 ALTER TABLE `email_replyto` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_replyto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emails` (
  `emailID` char(36) NOT NULL,
  `resendCount` int(10) unsigned DEFAULT NULL,
  `senderName` varchar(255) DEFAULT NULL,
  `senderAddress` varchar(255) NOT NULL,
  `charset` varchar(255) DEFAULT NULL,
  `messageContentType` varchar(255) DEFAULT NULL,
  `subject` mediumtext,
  `message` longtext,
  `lastSent` timestamp NULL DEFAULT NULL,
  `owner` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`emailID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emails`
--

LOCK TABLES `emails` WRITE;
/*!40000 ALTER TABLE `emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `minimal_user_attributes`
--

DROP TABLE IF EXISTS `minimal_user_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `minimal_user_attributes` (
  `userID` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(1024) NOT NULL,
  PRIMARY KEY (`userID`,`name`),
  KEY `Index_2` (`name`),
  CONSTRAINT `FK_minimal_user_attributes_1` FOREIGN KEY (`userID`) REFERENCES `minimal_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `minimal_user_attributes`
--

LOCK TABLES `minimal_user_attributes` WRITE;
/*!40000 ALTER TABLE `minimal_user_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `minimal_user_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `minimal_user_groups`
--

DROP TABLE IF EXISTS `minimal_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `minimal_user_groups` (
  `userID` int(10) unsigned NOT NULL,
  `groupID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`userID`,`groupID`),
  CONSTRAINT `FK_minimal_user_groups_1` FOREIGN KEY (`userID`) REFERENCES `minimal_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `minimal_user_groups`
--

LOCK TABLES `minimal_user_groups` WRITE;
/*!40000 ALTER TABLE `minimal_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `minimal_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `minimal_users`
--

DROP TABLE IF EXISTS `minimal_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `minimal_users` (
  `userID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `firstname` varchar(30) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastlogin` timestamp NULL DEFAULT '0000-00-00 00:00:00',
  `language` varchar(76) DEFAULT NULL,
  `preferedDesign` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `minimal_users`
--

LOCK TABLES `minimal_users` WRITE;
/*!40000 ALTER TABLE `minimal_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `minimal_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_module_aliases`
--

DROP TABLE IF EXISTS `openhierarchy_background_module_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_module_aliases` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alias` varchar(255) NOT NULL,
  `listIndex` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`,`alias`),
  CONSTRAINT `FK_backgroundmodulealiases_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1305 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_module_aliases`
--

LOCK TABLES `openhierarchy_background_module_aliases` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_module_aliases` DISABLE KEYS */;
INSERT INTO `openhierarchy_background_module_aliases` VALUES (7,'overview',0),(15,'*',0),(16,'overview',0),(18,'overview',0),(19,'*',0),(53,'*',0),(97,'overview*',0),(98,'overview',0),(99,'overview',0),(148,'overview',0),(149,'overview',0),(150,'overview',0),(171,'overview*',0),(177,'overview',0),(209,'*',0),(378,'*',0),(379,'overview',0),(458,'*',0);
/*!40000 ALTER TABLE `openhierarchy_background_module_aliases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_module_attributes`
--

DROP TABLE IF EXISTS `openhierarchy_background_module_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_module_attributes` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`moduleID`,`name`),
  CONSTRAINT `FK_openhierarchy_background_module_attributes_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1305 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_module_attributes`
--

LOCK TABLES `openhierarchy_background_module_attributes` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_module_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_background_module_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_module_groups`
--

DROP TABLE IF EXISTS `openhierarchy_background_module_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_module_groups` (
  `moduleID` int(10) unsigned NOT NULL,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`moduleID`,`groupID`),
  KEY `FK_backgroundmodulegroups_2` (`groupID`),
  CONSTRAINT `FK_backgroundmodulegroups_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_module_groups`
--

LOCK TABLES `openhierarchy_background_module_groups` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_module_groups` DISABLE KEYS */;
INSERT INTO `openhierarchy_background_module_groups` VALUES (16,8),(16,31);
/*!40000 ALTER TABLE `openhierarchy_background_module_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_module_settings`
--

DROP TABLE IF EXISTS `openhierarchy_background_module_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_module_settings` (
  `counter` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `moduleID` int(10) unsigned NOT NULL,
  `id` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`counter`),
  KEY `FK_backgroundmodulesettings_1` (`moduleID`),
  CONSTRAINT `FK_backgroundmodulesettings_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1267 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_module_settings`
--

LOCK TABLES `openhierarchy_background_module_settings` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_module_settings` DISABLE KEYS */;
INSERT INTO `openhierarchy_background_module_settings` VALUES (372,18,'connectorModuleAlias','eventconnector'),(373,18,'eventCount','3'),(374,19,'membersCount','5'),(600,171,'eventCount','3'),(781,7,'cssClass','of-module'),(782,7,'html','<div class=\"add-module of-hide-to-lg\"><a class=\"of-icon of-icon-md\" data-of-open-modal=\"new-widget\" href=\"#\" onclick=\"alert(\'Det går ännu inte att lägga till widgetar själv\')\"><i><svg viewbox=\"0 0 512 512\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><use xlink:href=\"#plus\"></use></svg></i> <span>Ny widget</span> </a></div>\r\n'),(783,7,'htmlRequired','true'),(1236,16,'cssClass','of-module'),(1237,16,'html','<div style=\"margin-bottom: 1em\"><a class=\"of-btn of-btn-center of-btn-gronsta of-icon\" href=\"/addsection\"><span>Skapa samarbetsrum</span> </a></div>\r\n'),(1238,16,'htmlRequired','true'),(1245,378,'welcomeMessage','<header>\r\n	<h1 style=\"color: rgb(0, 100, 172); font-size: 2em; margin-bottom: 0px;\">V&auml;lkommen till samarbetsrum!</h1>\r\n</header>\r\n<p style=\"margin-bottom: 0.3em; line-height: 1.2em; font-size: 0.97em;\">Du befinner dig nu p&aring; startsidan. H&auml;r kan du se alla samarbetsrum, sammanfattningar fr&aring;n dem, din kalender, uppgifter och favoriter.</p>\r\n<p style=\"margin-bottom: 0.3em; line-height: 1.2em; font-size: 0.97em;\">Helt enkelt allt som &auml;r unikt f&ouml;r just dig. &Aring;terkom alltid hit f&ouml;r en bra &ouml;versikt av dina samarbetsrum.</p>\r\n<p style=\"margin-bottom: 0.3em; text-align: center; font-size: 0.97em;\"><img alt=\"\" src=\"/images/rooms.png\" ></p>\r\n<p style=\"margin-bottom: 0.3em; line-height: 1.2em; font-size: 0.97em;\">Samarbetsrummen skapar du sj&auml;lv eller bjuds in i. I dessa samarbetar du med dina kollegor och delar allt med dem.</p>\r\n<p style=\"margin-bottom: 0.3em; line-height: 1.2em; font-size: 0.97em;\">Det &auml;r skillnaden p&aring; startsidan och samarbetsrummen - jaget och laget!</p>\r\n<h3 style=\"font-size: 1.1em; text-transform: none; padding: 0px; border: medium none; color: rgb(0, 100, 172);\">Tips!</h3>\r\n<p style=\"margin-bottom: 0; line-height: 1.2em; font-size: 0.97em;\">Anv&auml;nd s&ouml;kfunktionen h&ouml;gst upp f&ouml;r att hitta saker i Samarbetsrum</p>\r\n\r\n'),(1246,458,'cssClass','htmloutputmodule'),(1247,458,'html','<ul class=\"of-footer-list\">\r\n	<li><a href=\"/223\">Om samarbetsrum</a></li>\r\n</ul>\r\n'),(1248,458,'htmlRequired','true');
/*!40000 ALTER TABLE `openhierarchy_background_module_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_module_slots`
--

DROP TABLE IF EXISTS `openhierarchy_background_module_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_module_slots` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `slot` varchar(255) NOT NULL,
  PRIMARY KEY (`moduleID`,`slot`),
  CONSTRAINT `FK_backgroundmoduleslots_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1305 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_module_slots`
--

LOCK TABLES `openhierarchy_background_module_slots` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_module_slots` DISABLE KEYS */;
INSERT INTO `openhierarchy_background_module_slots` VALUES (7,'main-right'),(15,'header'),(16,'left-menu'),(18,'main-bottom'),(19,'main-top'),(53,'header'),(97,'main-top'),(98,'main-right'),(99,'main-right'),(148,'main-right'),(149,'main-right'),(150,'main-right'),(171,'main-top'),(177,'main-right'),(209,'notifications'),(378,'main-bottom'),(379,'main-top'),(458,'footer');
/*!40000 ALTER TABLE `openhierarchy_background_module_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_module_users`
--

DROP TABLE IF EXISTS `openhierarchy_background_module_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_module_users` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`,`userID`),
  CONSTRAINT `FK_backgroundmoduleusers_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_background_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_module_users`
--

LOCK TABLES `openhierarchy_background_module_users` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_module_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_background_module_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_background_modules`
--

DROP TABLE IF EXISTS `openhierarchy_background_modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_background_modules` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `classname` varchar(255) NOT NULL DEFAULT '',
  `name` text NOT NULL,
  `xslPath` text,
  `xslPathType` varchar(255) DEFAULT NULL,
  `anonymousAccess` tinyint(1) NOT NULL DEFAULT '0',
  `userAccess` tinyint(1) NOT NULL DEFAULT '0',
  `adminAccess` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `sectionID` int(10) unsigned NOT NULL DEFAULT '0',
  `dataSourceID` int(10) unsigned DEFAULT NULL,
  `staticContentPackage` varchar(255) DEFAULT NULL,
  `priority` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`),
  KEY `FK_backgroundmodules_1` (`sectionID`),
  KEY `FK_backgroundmodules_2` (`dataSourceID`),
  CONSTRAINT `FK_backgroundmodules_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_backgroundmodules_2` FOREIGN KEY (`dataSourceID`) REFERENCES `openhierarchy_data_sources` (`dataSourceID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1305 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_background_modules`
--

LOCK TABLES `openhierarchy_background_modules` WRITE;
/*!40000 ALTER TABLE `openhierarchy_background_modules` DISABLE KEYS */;
INSERT INTO `openhierarchy_background_modules` VALUES (7,'se.unlogic.hierarchy.backgroundmodules.htmloutput.HTMLOutputModule','Ny widget','HTMLOutputModule.sv.xsl','Classpath',1,1,1,0,1,NULL,'staticcontent',10),(15,'se.sundsvall.collaborationroom.modules.mysections.MySectionsBackgroundModule','Välj rum','MySectionsBackgroundModule.sv.xsl','Classpath',0,1,1,1,1,NULL,'staticcontent',0),(16,'se.unlogic.hierarchy.backgroundmodules.htmloutput.HTMLOutputModule','Skapa samarbetsrum (knapp)','HTMLOutputModule.sv.xsl','Classpath',0,1,0,1,1,NULL,NULL,0),(18,'se.sundsvall.collaborationroom.modules.lastestevents.LatestEventsBackgroundModule','Senaste händelserna','LatestEventsBackgroundModule.sv.xsl','Classpath',1,1,1,1,12,NULL,'staticcontent',0),(19,'se.sundsvall.collaborationroom.modules.overview.OverviewBackgroundModule','Översikt - Samarbetsrum','OverviewBackgroundModule.sv.xsl','Classpath',1,1,1,1,12,NULL,'staticcontent',0),(53,'se.dosf.communitybase.modules.search.SearchBackgroundModule','Sök (bakgrund)','SearchBackgroundModule.sv.xsl','Classpath',0,1,1,1,1,NULL,'staticcontent',1),(97,'se.sundsvall.collaborationroom.modules.blog.LatestUserPostsBackgroundModule','Senaste inläggen (bakgrund)','LatestUserPostsModule.sv.xsl','Classpath',0,1,1,1,1,NULL,'staticcontent',1),(98,'se.sundsvall.collaborationroom.modules.calendar.CalendarBackgroundModule','Kalender','CalendarBackgroundModule.sv.xsl','Classpath',0,1,0,1,12,NULL,'staticcontent',0),(99,'se.sundsvall.collaborationroom.modules.task.TasksBackgroundModule','Uppgifter','TasksBackgroundModule.sv.xsl','Classpath',0,1,0,1,12,NULL,'staticcontent',0),(148,'se.sundsvall.collaborationroom.modules.favourites.SectionFavouritesBackgroundModule','Favoriter','SectionFavouritesBackgroundModule.sv.xsl','Classpath',0,1,0,1,1,NULL,'',3),(149,'se.sundsvall.collaborationroom.modules.calendar.UserCalendarBackgroundModule','Min kalender','CalendarBackgroundModule.sv.xsl','Classpath',0,1,0,1,1,NULL,'staticcontent',0),(150,'se.sundsvall.collaborationroom.modules.task.MyTasksBackgroundModule','Mina uppgifter','MyTasksBackgroundModule.sv.xsl','Classpath',0,1,0,1,1,NULL,'staticcontent',1),(171,'se.sundsvall.collaborationroom.modules.preferedsections.PreferedSectionsBackgroundModule','Samarbetsrum - Widgets','PreferedSectionsBackgroundModule.sv.xsl','Classpath',0,1,0,1,1,NULL,'staticcontent',0),(177,'se.sundsvall.collaborationroom.modules.link.LinkArchiveBackgroundModule','Länkar','LinkArchiveBackgroundModule.sv.xsl','Classpath',0,1,0,1,12,NULL,'staticcontent',3),(209,'se.dosf.communitybase.modules.notifications.NotificationBackgroundModule','Notifikationsmeny','NotificationBackgroundModule.sv.xsl','Classpath',0,1,0,1,1,NULL,'staticcontent',0),(378,'se.sundsvall.collaborationroom.modules.login.FirstLoginBackgroundModule','Välkommen till Samarbetsrum','FirstLoginBackgroundModule.sv.xsl','Classpath',0,1,0,0,1,NULL,NULL,0),(379,'se.sundsvall.collaborationroom.modules.overview.ShortCutsBackgroundModule','Genvägar','ShortCutsBackgroundModuleTemplates.xsl','Classpath',0,1,0,1,12,NULL,'',1),(458,'se.unlogic.hierarchy.backgroundmodules.htmloutput.HTMLOutputModule','Sidfot','HTMLOutputModule.sv.xsl','Classpath',1,1,0,1,1,NULL,'staticcontent',0);
/*!40000 ALTER TABLE `openhierarchy_background_modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_data_sources`
--

DROP TABLE IF EXISTS `openhierarchy_data_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_data_sources` (
  `dataSourceID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(45) NOT NULL DEFAULT '',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `driver` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `logAbandoned` tinyint(1) DEFAULT '0',
  `removeAbandoned` tinyint(1) DEFAULT '0',
  `removeTimeout` int(10) unsigned DEFAULT '30',
  `testOnBorrow` tinyint(1) DEFAULT '0',
  `validationQuery` varchar(255) DEFAULT 'SELECT 1',
  `maxActive` int(10) unsigned DEFAULT '30',
  `maxIdle` int(10) unsigned DEFAULT '8',
  `minIdle` int(10) unsigned DEFAULT '0',
  `maxWait` int(10) unsigned DEFAULT '0',
  `defaultCatalog` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`dataSourceID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_data_sources`
--

LOCK TABLES `openhierarchy_data_sources` WRITE;
/*!40000 ALTER TABLE `openhierarchy_data_sources` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_data_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_filter_module_aliases`
--

DROP TABLE IF EXISTS `openhierarchy_filter_module_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_filter_module_aliases` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alias` varchar(255) NOT NULL,
  `listIndex` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`,`alias`),
  CONSTRAINT `FK_filtermodulealiases_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_filter_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_filter_module_aliases`
--

LOCK TABLES `openhierarchy_filter_module_aliases` WRITE;
/*!40000 ALTER TABLE `openhierarchy_filter_module_aliases` DISABLE KEYS */;
INSERT INTO `openhierarchy_filter_module_aliases` VALUES (1,'invitations*',0),(1,'login',1),(1,'newpassword',2),(2,'*',0);
/*!40000 ALTER TABLE `openhierarchy_filter_module_aliases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_filter_module_attributes`
--

DROP TABLE IF EXISTS `openhierarchy_filter_module_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_filter_module_attributes` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`moduleID`,`name`),
  CONSTRAINT `FK_openhierarchy_filter_module_attributes_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_filter_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_filter_module_attributes`
--

LOCK TABLES `openhierarchy_filter_module_attributes` WRITE;
/*!40000 ALTER TABLE `openhierarchy_filter_module_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_filter_module_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_filter_module_groups`
--

DROP TABLE IF EXISTS `openhierarchy_filter_module_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_filter_module_groups` (
  `moduleID` int(10) unsigned NOT NULL,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`moduleID`,`groupID`),
  KEY `FK_filtermodulegroups_2` (`groupID`),
  CONSTRAINT `FK_filtermodulegroups_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_filter_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_filter_module_groups`
--

LOCK TABLES `openhierarchy_filter_module_groups` WRITE;
/*!40000 ALTER TABLE `openhierarchy_filter_module_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_filter_module_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_filter_module_settings`
--

DROP TABLE IF EXISTS `openhierarchy_filter_module_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_filter_module_settings` (
  `counter` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `moduleID` int(10) unsigned NOT NULL,
  `id` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`counter`),
  KEY `FK_filtermodulesettings_1` (`moduleID`),
  CONSTRAINT `FK_filtermodulesettings_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_filter_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_filter_module_settings`
--

LOCK TABLES `openhierarchy_filter_module_settings` WRITE;
/*!40000 ALTER TABLE `openhierarchy_filter_module_settings` DISABLE KEYS */;
INSERT INTO `openhierarchy_filter_module_settings` VALUES (3,1,'design','content-only');
/*!40000 ALTER TABLE `openhierarchy_filter_module_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_filter_module_users`
--

DROP TABLE IF EXISTS `openhierarchy_filter_module_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_filter_module_users` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`,`userID`),
  CONSTRAINT `FK_filtermoduleusers_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_filter_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_filter_module_users`
--

LOCK TABLES `openhierarchy_filter_module_users` WRITE;
/*!40000 ALTER TABLE `openhierarchy_filter_module_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_filter_module_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_filter_modules`
--

DROP TABLE IF EXISTS `openhierarchy_filter_modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_filter_modules` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `classname` varchar(255) NOT NULL DEFAULT '',
  `name` text NOT NULL,
  `anonymousAccess` tinyint(1) NOT NULL DEFAULT '0',
  `userAccess` tinyint(1) NOT NULL DEFAULT '0',
  `adminAccess` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `dataSourceID` int(10) unsigned DEFAULT NULL,
  `priority` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`),
  KEY `FK_filtermodules_1` (`dataSourceID`),
  CONSTRAINT `FK_filtermodules_1` FOREIGN KEY (`dataSourceID`) REFERENCES `openhierarchy_data_sources` (`dataSourceID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_filter_modules`
--

LOCK TABLES `openhierarchy_filter_modules` WRITE;
/*!40000 ALTER TABLE `openhierarchy_filter_modules` DISABLE KEYS */;
INSERT INTO `openhierarchy_filter_modules` VALUES (1,'se.samarbetsrum.gislaved.modules.SwitchDesignFilterModule','Byt design',1,1,1,1,NULL,0),(2,'se.unlogic.hierarchy.filtermodules.login.LoginTriggerModule','LoginTriggerModule',1,0,0,1,NULL,0);
/*!40000 ALTER TABLE `openhierarchy_filter_modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_foreground_module_attributes`
--

DROP TABLE IF EXISTS `openhierarchy_foreground_module_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_foreground_module_attributes` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`moduleID`,`name`),
  CONSTRAINT `FK_openhierarchy_foreground_module_attributes_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_foreground_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2320 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_foreground_module_attributes`
--

LOCK TABLES `openhierarchy_foreground_module_attributes` WRITE;
/*!40000 ALTER TABLE `openhierarchy_foreground_module_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_foreground_module_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_foreground_module_groups`
--

DROP TABLE IF EXISTS `openhierarchy_foreground_module_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_foreground_module_groups` (
  `moduleID` int(10) unsigned NOT NULL,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`moduleID`,`groupID`),
  KEY `FK_modulegroups_2` (`groupID`),
  CONSTRAINT `FK_modulegroups_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_foreground_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_foreground_module_groups`
--

LOCK TABLES `openhierarchy_foreground_module_groups` WRITE;
/*!40000 ALTER TABLE `openhierarchy_foreground_module_groups` DISABLE KEYS */;
INSERT INTO `openhierarchy_foreground_module_groups` VALUES (16,8),(37,8),(39,8),(69,8),(70,8),(112,8),(148,8),(208,8),(2320,8),(16,9),(37,9),(69,9),(70,9),(148,31);
/*!40000 ALTER TABLE `openhierarchy_foreground_module_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_foreground_module_settings`
--

DROP TABLE IF EXISTS `openhierarchy_foreground_module_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_foreground_module_settings` (
  `counter` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `moduleID` int(10) unsigned NOT NULL,
  `id` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`counter`),
  KEY `FK_modulesettings_1` (`moduleID`),
  CONSTRAINT `FK_modulesettings_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_foreground_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22221 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_foreground_module_settings`
--

LOCK TABLES `openhierarchy_foreground_module_settings` WRITE;
/*!40000 ALTER TABLE `openhierarchy_foreground_module_settings` DISABLE KEYS */;
INSERT INTO `openhierarchy_foreground_module_settings` VALUES (842,84,'menuItemType','MENUITEM'),(864,64,'menuItemType','MENUITEM'),(2241,70,'menuItemType','MENUITEM'),(2249,37,'menuItemType','MENUITEM'),(2252,69,'menuItemType','MENUITEM'),(2253,16,'allowAdminAdministration','false'),(2254,16,'allowGroupAdministration','true'),(2255,16,'filteringField','FIRSTNAME'),(2256,16,'menuItemType','MENUITEM'),(2257,56,'menuItemType','MENUITEM'),(3727,89,'allowPasswordChanging','true'),(3728,89,'emailFieldMode','REQUIRED'),(3729,89,'firstnameFieldMode','REQUIRED'),(3730,89,'lastnameFieldMode','REQUIRED'),(3731,89,'menuItemType','SECTION'),(3732,89,'usernameFieldMode','REQUIRED'),(3793,142,'maxEventQueueSize','200'),(3794,142,'menuItemType','MENUITEM'),(3795,142,'minEventQueueSize','180'),(3814,151,'eventStylesheet','BlogEvent.sv.xsl'),(3815,151,'menuItemType','MENUITEM'),(3816,151,'postLoadCount','2'),(3817,151,'tagHitCount','30'),(3818,152,'menuItemType','MENUITEM'),(3819,154,'eventCount','3'),(3820,154,'menuItemType','MENUITEM'),(3822,155,'cssPath','/css/fck.css'),(3823,155,'diskThreshold','100'),(3824,155,'eventStylesheet','PageEvent.sv.xsl'),(3825,155,'menuItemType','MENUITEM'),(3826,155,'ramThreshold','500'),(3827,157,'menuItemType','MENUITEM'),(3828,157,'postLoadCount','3'),(4014,196,'menuItemType','MENUITEM'),(4015,134,'menuItemType','SECTION'),(4016,134,'redirectURL','/login'),(4053,116,'menuItemType','MENUITEM'),(4054,116,'message','Hej $user.firstname,\r\n	\r\nHär ditt nya lösenord till Samarbetsrum: $password\r\n\r\n/ Samarbetsrum'),(4055,116,'newPasswordFormMessage','<h1>Beg&auml;r nytt l&ouml;senord</h1>\r\n<p>Fyll i formul&auml;ret nedan f&ouml;r att f&aring; ett nytt l&ouml;senord skickat till dig.</p>\r\n'),(4056,116,'newPasswordSentMessage','<h1>Beg&auml;r nytt l&ouml;senord</h1>\r\n<p>Ett nytt l&ouml;senord har skickats till dig.</p>\r\n'),(4057,116,'requireCaptchaConfirmation','true'),(4058,116,'requireUsername','false'),(4060,116,'senderName','Samarbetsrum'),(4061,116,'subject','Nytt lösenord till Samarbetsrum'),(4094,208,'emailFieldMode','OPTIONAL'),(4095,208,'formStyleSheet','MinimalUserProviderForm.sv.xsl'),(4096,208,'includeDebugData','false'),(4097,208,'menuItemType','MENUITEM'),(4098,208,'passwordAlgorithm','SHA-1'),(4099,208,'passwordFieldMode','DISABLED'),(4100,208,'priority','0'),(4101,208,'supportedAttributes','phone!:Telefon\r\norganizationID!:Organisations ID\r\norganization!:Organisation'),(4102,208,'userTypeName','MinimalUser'),(4103,208,'usernameFieldMode','REQUIRED'),(4645,96,'menuItemType','MENUITEM'),(4664,393,'menuItemType','MENUITEM'),(4665,394,'menuItemType','MENUITEM'),(4666,394,'postLoadCount','5'),(4699,71,'formStyleSheet','SimpleUserProviderForm.sv.xsl'),(4700,71,'includeDebugData','false'),(4701,71,'menuItemType','MENUITEM'),(4702,71,'passwordAlgorithm','SHA-1'),(4703,71,'priority','0'),(4704,71,'supportedAttributes','isExternal:Extern användare'),(4705,71,'userTypeName','SimpleUser'),(4882,61,'maxFileSize','1'),(4883,61,'maxRequestSize','5'),(4884,61,'menuItemType','MENUITEM'),(4885,61,'ramThreshold','500'),(5025,474,'maxPreferedSections','3'),(5026,474,'menuItemType','MENUITEM'),(5050,484,'linksLoadCount','5'),(5051,484,'menuItemType','MENUITEM'),(5060,516,'menuItemType','MENUITEM'),(5061,516,'notificationCount','3'),(5062,516,'notificationDeleteInterval','0 * * * *'),(5063,516,'notificationLifetime','31'),(5489,266,'logItemParsing','false'),(5490,266,'maxContentHitCount','100'),(5491,266,'maxJsonSectionHitCount','5'),(5492,266,'maxJsonTagsHitCount','5'),(5493,266,'maxJsonUserHitCount','5'),(5494,266,'maxSectionHitCount','20'),(5495,266,'maxTagsHitCount','20'),(5496,266,'maxUserHitCount','20'),(5497,266,'menuItemType','MENUITEM'),(5498,266,'poolSize','2'),(5530,698,'icalAvailableMessage','<div class=\"of-inner-padded-trl\">\r\n	<h1>Prenumerera p&aring; kalender</h1>\r\n</div>\r\n<div class=\"of-inner-padded-trl\">\r\n	<p>Via l&auml;nken nedan s&aring; kan du prenumerera p&aring; denna kalender via exempelvis Outlook eller Gmail.</p>\r\n	<p>T&auml;nk dock p&aring; att det via denna l&auml;nk g&aring;r att komma &aring;t kalenderns inneh&aring;ll utan n&aring;gon inloggning s&aring; dela inte med dig av denna l&auml;nk till n&aring;gon annan. L&auml;nken &auml;r personlig och kopplad till ditt anv&auml;ndarkonto.</p>\r\n</div>\r\n'),(5531,698,'icalNotAvailableMessage','<div class=\"of-inner-padded-trl\">\r\n	<h1>Prenumerera p&aring; kalender</h1>\r\n</div>\r\n<div class=\"of-inner-padded-trl\">Den h&auml;r funktionen &auml;r tyv&auml;rr inte tillg&auml;nglig f&ouml;r ditt anv&auml;ndarkonto.</div>\r\n'),(5532,698,'language','sv-SE'),(5533,698,'menuItemType','MENUITEM'),(5584,39,'csspath','/css/fck.css'),(5585,39,'disablePreview','true'),(5586,39,'diskThreshold','100'),(5588,39,'menuItemType','MENUITEM'),(5589,39,'pageViewModuleAlias','page'),(5590,39,'pageViewModuleName','Page viewer'),(5591,39,'pageViewModuleXSLPath','PageViewModule.sv.xsl'),(5592,39,'pageViewModuleXSLPathType','Classpath'),(5593,39,'ramThreshold','500'),(5794,800,'defaultResumeHour','16'),(5795,800,'menuItemType','MENUITEM'),(5796,800,'redirectAlias','/userprofile'),(5797,800,'supportedModuleNotifications','149:Deltagare och medlemskap'),(5798,800,'supportedModuleNotifications','151:Inlägg och kommentarer'),(5799,800,'supportedModuleNotifications','156:Uppgifter'),(6782,147,'menuItemType','MENUITEM'),(6783,147,'sectionLoadCount','6'),(7118,875,'managersFoundMessage','<h1>&Aring;tkomst nekad!</h1>\n\n<p>F&ouml;r att komma &aring;t samarbetsrummet <strong>$section.name</strong> m&aring;ste du bli inbjuden.</p>\n\n<p>Kontakta n&aring;gon av administrat&ouml;rerna f&ouml;r samarbetsrummet nedan om du vill bli inbjuden.</p>\n\n'),(7119,875,'managersNotFoundMessage','<h1>&Aring;tkomst nekad!</h1>\n\n<p>F&ouml;r att komma &aring;t samarbetsrummet <strong>$section.name</strong> m&aring;ste du bli inbjuden.</p>\n\n<p>Inga administrat&ouml;rer f&ouml;r samarbetsrummet hittades, kontakta systemadministrat&ouml;ren f&ouml;r mer information.</p>\n\n'),(7120,875,'menuItemType','MENUITEM'),(7121,875,'priority','0'),(7877,1016,'deleteDelay','31'),(7878,1016,'menuItemType','MENUITEM'),(7879,1016,'message','<header class=\"of-inner-padded-trl of-inner-padded-t-half\">\r\n	<h1><span>Ta bort samarbetsrum</span></h1>\r\n</header>\r\n<div class=\"of-inner-padded-rl of-inner-padded-tb-half\">\r\n	<p>&Auml;r du helt s&auml;ker p&aring; att du vill ta bort samarbetsrummet <strong>$section.name</strong>?</p>\r\n	<p>N&auml;r du v&auml;ljer att ta bort ett rum s&aring; raderas allt inneh&aring;ll i rummet. Filer, uppgifter, inl&auml;gg etc. L&auml;nkar som pekar p&aring; inneh&aring;ll i ditt rum kommer att sluta fungera.</p>\r\n	<p>Ett borttaget rum tas bort permanent och kan inte &aring;terskapas.</p>\r\n</div>\r\n'),(7880,1016,'sectionDeleteInterval','0 * * * *'),(14691,149,'followRoleID','3'),(14692,149,'groupFilterAttribute','smexOrganizationID'),(14693,149,'menuItemType','MENUITEM'),(14694,149,'notificationStylesheet','MemberNotification.sv.xsl'),(17642,150,'diskThreshold','100'),(17643,150,'eventStylesheet','FileEvent.sv.xsl'),(17644,150,'extensions','doc'),(17645,150,'extensions','docx'),(17646,150,'extensions','ppt'),(17647,150,'extensions','pptx'),(17648,150,'extensions','xls'),(17649,150,'extensions','xlsx'),(17650,150,'extensions','txt'),(17651,150,'extensions','odt'),(17652,150,'extensions','odf'),(17653,150,'extensions','pdf'),(17654,150,'extensions','jpg'),(17655,150,'extensions','jpeg'),(17656,150,'extensions','png'),(17657,150,'extensions','gif'),(17658,150,'extensions','psd'),(17659,150,'extensions','eps'),(17660,150,'extensions','rtf'),(17661,150,'extensions','xmind'),(17662,150,'extensions','html'),(17663,150,'extensions','vsd'),(17664,150,'fileLockTime','4'),(17665,150,'maxFileSize','15'),(17666,150,'menuItemType','MENUITEM'),(17667,150,'ramThreshold','500'),(17668,150,'tagHitCount','30'),(21743,115,'adminTimeout','120'),(21744,115,'default','true'),(21745,115,'defaultRedirectAlias','/'),(21746,115,'logoutModuleAliases','/logout\r\n/logout/logout'),(21747,115,'menuItemType','MENUITEM'),(21748,115,'newPasswordModuleAlias','/newpassword'),(21749,115,'priority','100'),(21750,115,'userTimeout','60'),(21751,137,'emailMessage','<p>Hej!</p>\r\n<p>Du har blivit inbjuden till Samarbetsrum. Du har f&aring;tt tillg&aring;ng till f&ouml;ljande samarbetsrum:</p>\r\n<p>$role-list</p>\r\n<p>Klicka p&aring; l&auml;nken nedan f&ouml;r att skapa ett anv&auml;ndarkonto:</p>\r\n<p><a href=\"$invitation-link\">$invitation-link</a></p>\r\n'),(21752,137,'emailSender','Samarbetsrum'),(21754,137,'emailSubject','Inbjudan till Samarbetsrum'),(21755,137,'menuItemType','MENUITEM'),(21756,137,'registrationText','<h1 class=\"of-inner-padded-t-half\">V&auml;lkommen till Samarbetsrum</h1>\r\n<p class=\"of-inner-padded-t-half\">B&ouml;rja med att fylla i information om dig sj&auml;lv. Har du redan ett konto? <a href=\"??RELATIVE_FROM_CONTEXTPATH??/login\">Klicka h&auml;r</a></p>\r\n'),(21757,106,'connectionTimeout','10000'),(21758,106,'daoFactoryClass','se.unlogic.hierarchy.foregroundmodules.mailsenders.persisting.daos.mysql.MySQLMailDAOFactory'),(21759,106,'databaseID','3'),(21760,106,'exceptionInterval','60000'),(21762,106,'maxExceptionCount','5'),(21763,106,'maxQueueSize','50'),(21764,106,'maxResendCount','3'),(21765,106,'menuItemType','MENUITEM'),(21766,106,'noWorkInterval','10000'),(21767,106,'poolSize','10'),(21769,106,'priority','0'),(21770,106,'queueFullInterval','3000'),(21771,106,'resendInterval','30'),(21772,106,'shutdownTimeout','60000'),(21773,106,'socketTimeout','600000'),(21774,106,'useAuth','false'),(21783,136,'menuItemType','MENUITEM'),(21784,148,'maxRequestSize','100'),(21785,148,'menuItemType','MENUITEM'),(21786,148,'ramThreshold','500'),(21787,148,'sectionImageSize','270'),(21838,801,'defaultResumeHour','16'),(21840,801,'emailSenderName','Samarbetsrum'),(21841,801,'emailSubject','Resumé från Samarbetsrum'),(21843,801,'mailEventsSection','<h2>Nya h&auml;ndelser i rummet $section.name</h2>\r\n<p>$events</p>\r\n'),(21844,801,'mailFooter','<p><a href=\"$siteURL\">Klicka h&auml;r f&ouml;r att komma till Samarbetsrum</a>.</p>\r\n<p><a href=\"$notificationSettings\">Klicka h&auml;r f&ouml;r att &auml;ndra dina inst&auml;llningar f&ouml;r e-post resum&eacute;n.</a></p>\r\n'),(21845,801,'mailHeader','<h1>Hej $user.firstname</h1>\r\n<p>H&auml;r kommer en resum&eacute; med vad som h&auml;nt i Samarbetsrum sedan ditt senaste bes&ouml;k.</p>\r\n'),(21846,801,'mailNotificationSection','<h2>Nya notifikationer</h2>\r\n<p>$notifications</p>\r\n'),(21847,801,'menuItemType','MENUITEM'),(21848,801,'notificationSettingsModuleAlias','/resumesettings'),(21849,801,'sectionEventCount','10'),(21850,801,'ulStyle','list-style-type: none;'),(22205,2320,'menuItemType','MENUITEM'),(22206,2320,'message','<header class=\"of-inner-padded-trl of-inner-padded-t-half\">\r\n<h1><span>Ta bort samarbetsrum</span></h1>\r\n</header>\r\n\r\n<div class=\"of-inner-padded-rl of-inner-padded-tb-half\">\r\n<p>&Auml;r du helt s&auml;ker p&aring; att du vill ta bort samarbetsrummet <strong>$section.name</strong>?</p>\r\n\r\n<p>N&auml;r du v&auml;ljer att ta bort ett rum s&aring; raderas allt inneh&aring;ll i rummet. Filer, uppgifter, inl&auml;gg etc. L&auml;nkar som pekar p&aring; inneh&aring;ll i ditt rum kommer att sluta fungera.</p>\r\n\r\n<p>Ett borttaget rum tas bort permanent och kan inte &aring;terskapas.</p>\r\n</div>\r\n\r\n<p>&nbsp;</p>\r\n'),(22207,2320,'notificationStylesheet','SectionOverviewNotification.sv.xsl'),(22208,103,'allowAdminAdministration','true'),(22209,103,'allowGroupAdministration','true'),(22210,103,'allowUserSwitching','true'),(22211,103,'filteringField','FIRSTNAME'),(22212,103,'menuItemType','MENUITEM'),(22214,138,'diskThreshold','100'),(22215,138,'menuItemType','MENUITEM'),(22216,138,'profileImageSize','270'),(22217,138,'ramThreshold','500'),(22218,138,'resumeSettingsAlias','/resumesettings'),(22219,138,'setExternalUserAttribute','false'),(22220,138,'userClass','se.unlogic.hierarchy.foregroundmodules.minimaluser.MinimalUser');
/*!40000 ALTER TABLE `openhierarchy_foreground_module_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_foreground_module_users`
--

DROP TABLE IF EXISTS `openhierarchy_foreground_module_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_foreground_module_users` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`moduleID`,`userID`),
  CONSTRAINT `FK_moduleusers_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_foreground_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_foreground_module_users`
--

LOCK TABLES `openhierarchy_foreground_module_users` WRITE;
/*!40000 ALTER TABLE `openhierarchy_foreground_module_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_foreground_module_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_foreground_modules`
--

DROP TABLE IF EXISTS `openhierarchy_foreground_modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_foreground_modules` (
  `moduleID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `classname` varchar(255) NOT NULL DEFAULT '',
  `name` text NOT NULL,
  `alias` varchar(45) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `xslPath` text,
  `xslPathType` varchar(255) DEFAULT NULL,
  `anonymousAccess` tinyint(1) NOT NULL DEFAULT '0',
  `userAccess` tinyint(1) NOT NULL DEFAULT '0',
  `adminAccess` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `visibleInMenu` tinyint(1) NOT NULL DEFAULT '0',
  `sectionID` int(10) unsigned NOT NULL DEFAULT '0',
  `dataSourceID` int(10) unsigned DEFAULT NULL,
  `staticContentPackage` varchar(255) DEFAULT NULL,
  `requiredProtocol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`moduleID`),
  UNIQUE KEY `Index_3` (`sectionID`,`alias`),
  KEY `FK_modules_1` (`sectionID`),
  KEY `FK_modules_2` (`dataSourceID`),
  CONSTRAINT `FK_modules_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_modules_2` FOREIGN KEY (`dataSourceID`) REFERENCES `openhierarchy_data_sources` (`dataSourceID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2321 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_foreground_modules`
--

LOCK TABLES `openhierarchy_foreground_modules` WRITE;
/*!40000 ALTER TABLE `openhierarchy_foreground_modules` DISABLE KEYS */;
INSERT INTO `openhierarchy_foreground_modules` VALUES (16,'se.unlogic.hierarchy.foregroundmodules.useradmin.UserAdminModule','Användare','users','Användare','UserAdminModule.sv.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(17,'se.unlogic.hierarchy.foregroundmodules.userprofile.UserProfileModule','Mina inställningar','userprofile','Modul för ändring av användaruppgifter','userprofile.xsl','Classpath',0,1,1,1,1,0,NULL,NULL,NULL),(37,'se.unlogic.hierarchy.foregroundmodules.menuadmin.MenuAdminModule','Menyer','menuadmin','Menyer','MenuAdminModule.sv.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(39,'se.unlogic.hierarchy.foregroundmodules.pagemodules.PageAdminModule','Sidor','pageadmin','Sidor','PageAdminModule.sv.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontentadmin',NULL),(56,'se.unlogic.hierarchy.foregroundmodules.runtimeinfo.RuntimeInfoModule','Systeminfo','runtimeinfo','Systeminfo','RuntimeInfoModule.en.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(61,'se.unlogic.hierarchy.foregroundmodules.systemadmin.SystemAdminModule','Moduler och sektioner','systemadmin','Moduler och sektioner','SystemAdminModule.sv.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(64,'se.unlogic.hierarchy.foregroundmodules.threadinfo.ThreadInfoModule','Trådinfo','threadinfo','Trådinfo','ThreadInfoModule.en.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(67,'se.unlogic.hierarchy.foregroundmodules.staticcontent.StaticContentModule','Statiskt innehåll','static','Statiskt innehåll',NULL,NULL,1,1,1,1,0,1,NULL,NULL,NULL),(69,'se.unlogic.hierarchy.foregroundmodules.usersessionadmin.UserSessionAdminModule','Inloggade användare','sessionadmin','Inloggade användare','UserSessionAdminModule.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(70,'se.unlogic.hierarchy.foregroundmodules.groupadmin.GroupAdminModule','Grupper','groupadmin','Grupper','GroupAdminModule.sv.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(71,'se.unlogic.hierarchy.foregroundmodules.userproviders.SimpleUserProviderModule','SimpleUserProviderModule','userprovider','SimpleUserProviderModule',NULL,NULL,0,1,0,1,0,1,NULL,'/se/unlogic/hierarchy/foregroundmodules/useradmin/staticcontent',NULL),(84,'se.unlogic.hierarchy.foregroundmodules.datasourceadmin.DataSourceAdminModule','Datakällor','datasourceadmin','Datakällor','DataSourceAdminModule.en.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(89,'se.unlogic.hierarchy.foregroundmodules.userprofile.UserProfileModule','Mitt konto','userprofile_old','Mitt konto','UserProfileModule.sv.xsl','Classpath',0,1,1,1,0,1,NULL,NULL,NULL),(96,'se.unlogic.hierarchy.foregroundmodules.mailsenders.dummy.DummyEmailSenderModule','E-postsändare - Test','emailsendertest','Tar emot senast skickade e-postmeddelandet',NULL,NULL,0,0,1,0,0,4,NULL,NULL,NULL),(103,'se.unlogic.hierarchy.foregroundmodules.useradmin.UserAdminModule','Användare (admin)','useradmin1','Användare (admin)','UserAdminModule.sv.xsl','Classpath',0,0,1,1,1,4,NULL,'staticcontent',NULL),(106,'se.unlogic.hierarchy.foregroundmodules.mailsenders.dummy.DummyEmailSenderModule','E-post kö','mailsender','Modul för utskick av e-post',NULL,NULL,0,0,1,1,0,4,NULL,NULL,NULL),(110,'se.unlogic.hierarchy.foregroundmodules.test.XSLReload','Ladda om stilmall','xslreload','Ladda om stilmall',NULL,NULL,0,0,1,1,0,4,NULL,NULL,NULL),(112,'se.unlogic.hierarchy.foregroundmodules.htmloutput.HTMLOutputAdminModule','Administrera Widgets','htmloutputadmin','Administrera Widgets','HTMLOutputAdminModule.sv.xsl','Classpath',0,0,1,1,0,4,NULL,'staticcontent',NULL),(113,'se.unlogic.hierarchy.foregroundmodules.groupproviders.SimpleGroupProviderModule','SimpleGroupProvider','simplegroupprovider','A group provider for simple groups',NULL,NULL,0,0,0,1,0,1,NULL,NULL,NULL),(115,'se.sundsvall.collaborationroom.modules.login.LoginModule','Logga in','login','Logga in','LoginModule.sv.xsl','Classpath',1,0,0,1,0,1,NULL,'staticcontent',NULL),(116,'se.unlogic.hierarchy.foregroundmodules.newpassword.NewPasswordModule','Begär nytt lösenord','newpassword','Begär nytt lösenord','NewPasswordModule.sv.xsl','Classpath',1,0,0,1,0,1,NULL,'staticcontent',NULL),(134,'se.unlogic.hierarchy.foregroundmodules.logout.LogoutModule','Logga ut','logout','Logga ut','LogoutModule.sv.xsl','Classpath',0,1,1,1,0,1,NULL,NULL,NULL),(136,'se.dosf.communitybase.modules.CBCoreModule','CB Core','cbcore','CB Core',NULL,NULL,0,0,0,1,0,1,NULL,NULL,NULL),(137,'se.dosf.communitybase.modules.invitation.InvitationModule','Inbjudningar','invitations','Inbjudningar','InvitationModule.sv.xsl','Classpath',1,1,1,1,0,1,NULL,'staticcontent',NULL),(138,'se.dosf.communitybase.modules.userprofile.UserProfileModule','Min profil','userprofile','Min profil','UserProfileModule.sv.xsl','Classpath',0,1,1,1,0,1,NULL,'staticcontent',NULL),(139,'se.dosf.communitybase.modules.tagcache.TagCacheModule','Taggar (cache)','tagcache','Taggar (cache)',NULL,NULL,0,0,0,1,0,1,NULL,NULL,NULL),(142,'se.dosf.communitybase.modules.sectionevents.CBSectionEventHandler','CB Eventhanterare','eventhandler','CB Eventhanterare',NULL,NULL,0,0,1,1,0,4,NULL,NULL,NULL),(146,'se.dosf.communitybase.modules.favourites.SectionFavouriteModule','Favoriter','favourites','Favoriter',NULL,NULL,0,1,1,1,0,1,NULL,NULL,NULL),(147,'se.sundsvall.collaborationroom.modules.mysections.MySectionsModule','Min startsida','overview','Min startsida','MySectionsModule.sv.xsl','Classpath',0,1,1,1,1,1,NULL,'staticcontent',NULL),(148,'se.dosf.communitybase.modules.addsection.AddSectionModule','Skapa samarbetsrum','addsection','Skapa samarbetsrum','AddSectionModule.sv.xsl','Classpath',0,1,0,1,0,1,NULL,'staticcontent',NULL),(149,'se.sundsvall.collaborationroom.modules.members.MembersModule','Deltagare','members','Deltagare','MembersModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(150,'se.sundsvall.collaborationroom.modules.filearchive.FileArchiveModule','Filer','files','Filer','FileArchiveModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(151,'se.sundsvall.collaborationroom.modules.blog.BlogModule','Inlägg','posts','Inlägg','BlogModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(152,'se.sundsvall.collaborationroom.modules.settings.SettingsModule','Inställningar','settings','Inställningar','SettingsModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(153,'se.sundsvall.collaborationroom.modules.calendar.CalendarModule','Kalender','calendar','Kalender','CalendarModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(154,'se.sundsvall.collaborationroom.modules.lastestevents.LatestEventsConnectorModule','Senaste händelserna (connector)','eventconnector','Senaste händelserna (connector)',NULL,NULL,1,1,1,1,0,12,NULL,'staticcontent',NULL),(155,'se.sundsvall.collaborationroom.modules.page.PageModule','Sidor','pages','Sidor','PageModule.sv.xsl','Classpath',0,1,1,1,1,12,NULL,'staticcontent',NULL),(156,'se.sundsvall.collaborationroom.modules.task.TaskModule','Uppgifter','tasks','Uppgifter','TaskModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(157,'se.sundsvall.collaborationroom.modules.blog.LatestPostsModule','Överblick','overview','Överblick','LatestPostsModule.sv.xsl','Classpath',1,1,1,1,1,12,NULL,'staticcontent',NULL),(196,'se.dosf.communitybase.modules.util.CBUtilityModule','CB Utilities','cbutils','CB Utilities',NULL,NULL,0,1,1,1,0,1,NULL,NULL,NULL),(208,'se.unlogic.hierarchy.foregroundmodules.minimaluser.MinimalUserProviderModule','MinimalUserProviderModule','minimalusers','MinimalUserProviderModule','',NULL,0,0,0,1,0,1,NULL,'/se/unlogic/hierarchy/foregroundmodules/useradmin/staticcontent',NULL),(266,'se.dosf.communitybase.modules.search.SearchModule','Sök','search','Sök','SearchModule.sv.xsl','Classpath',0,1,1,1,0,1,NULL,'staticcontent',NULL),(393,'se.sundsvall.collaborationroom.modules.task.MyTasksModule','Mina uppgifter','mytasks','Mina uppgifter','MyTasksModule.sv.xsl','Classpath',0,1,1,1,1,1,NULL,'staticcontent',NULL),(394,'se.sundsvall.collaborationroom.modules.blog.LatestUserPostsModule','Senaste inläggen (connector)','latestposts','Senaste inläggen (connector)','LatestUserPostsModule.sv.xsl','Classpath',0,1,0,1,0,1,NULL,'staticcontent',NULL),(437,'se.sundsvall.collaborationroom.modules.calendar.UserCalendarModule','Min kalender','mycalendar','Min kalender','CalendarModule.sv.xsl','Classpath',0,1,0,1,1,1,NULL,'staticcontent',NULL),(474,'se.sundsvall.collaborationroom.modules.preferedsections.PreferedSectionsConnectorModule','Samarbetsrum - Widgets','preferedsections','Samarbetsrum - Widgets','',NULL,0,1,0,1,0,1,NULL,'',NULL),(484,'se.sundsvall.collaborationroom.modules.link.LinkArchiveModule','Länkar','links','Länkar','LinkArchiveModule.sv.xsl','Classpath',0,1,0,1,0,12,NULL,'staticcontent',NULL),(516,'se.dosf.communitybase.modules.notifications.NotificationHandlerModule','Notifikationer','notifications','Notifikationer','NotificationHandlerModule.sv.xsl','Classpath',0,1,1,1,0,1,NULL,NULL,NULL),(698,'se.sundsvall.collaborationroom.modules.calendar.ICalModule','iCal exporter','ical','iCal exporter',NULL,NULL,1,1,0,1,0,1,NULL,NULL,NULL),(799,'se.sundsvall.collaborationroom.modules.filearchive.FileArchiveUnlockerModule','File archive unlocker','filearchiveunlocker','File archive unlocker','',NULL,0,0,0,1,0,4,NULL,'',NULL),(800,'se.dosf.communitybase.modules.emailresume.EmailResumeSettingsModule','Inställningar för e-post resumé','resumesettings','Inställningar för e-post resumé','EmailResumeSettingsModule.sv.xsl','Classpath',0,1,0,1,0,1,NULL,'staticcontent',NULL),(801,'se.dosf.communitybase.modules.emailresume.EmailResumeModule','EmailResumeModule','resume','EmailResumeModule',NULL,NULL,0,0,1,1,0,4,NULL,NULL,NULL),(802,'se.dosf.communitybase.modules.settingscascade.ModuleSettingsCascadeModule','ModuleSettingsCascadeModule','settingscascade','ModuleSettingsCascadeModule','',NULL,0,0,0,1,0,4,NULL,'',NULL),(875,'se.dosf.communitybase.modules.sectionaccess.SectionAccessDeniedHandlerModule','Åtkomst nekad','sectionaccessdenied','Åtkomst nekad','SectionAccessDeniedHandlerModule.sv.xsl','Classpath',0,1,0,1,0,1,NULL,'',NULL),(1016,'se.dosf.communitybase.modules.deletesection.DeleteSectionModule','Ta bort samarbetsrum','delete','Ta bort samarbetsrum','DeleteSectionModule.sv.xsl','Classpath',0,1,0,1,0,1,NULL,NULL,NULL),(2320,'se.sundsvall.collaborationroom.modules.sectionoverview.SectionOverviewModule','Rumsöversikt','sectionoverview','Översikt av alla samarbetsrum','SectionOverviewModule.sv.xsl','Classpath',0,0,0,1,1,1,NULL,'staticcontent',NULL);
/*!40000 ALTER TABLE `openhierarchy_foreground_modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_menu_index`
--

DROP TABLE IF EXISTS `openhierarchy_menu_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_menu_index` (
  `menuIndexID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sectionID` int(10) unsigned NOT NULL DEFAULT '0',
  `menuIndex` int(10) unsigned NOT NULL DEFAULT '0',
  `moduleID` int(10) unsigned DEFAULT NULL,
  `uniqueID` varchar(255) DEFAULT NULL,
  `subSectionID` int(10) unsigned DEFAULT NULL,
  `menuItemID` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`menuIndexID`),
  UNIQUE KEY `UniqueID / ModuleID` (`moduleID`,`uniqueID`,`sectionID`),
  UNIQUE KEY `Index_5` (`sectionID`,`subSectionID`),
  KEY `FK_menuindex_3` (`subSectionID`),
  KEY `FK_menuindex_4` (`menuItemID`),
  CONSTRAINT `FK_menuindex_1` FOREIGN KEY (`moduleID`) REFERENCES `openhierarchy_foreground_modules` (`moduleID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_menuindex_2` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_menuindex_3` FOREIGN KEY (`subSectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_menuindex_4` FOREIGN KEY (`menuItemID`) REFERENCES `openhierarchy_virtual_menu_items` (`menuItemID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2403 DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; (`sectionID`) REFER `foraldramotet-o';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_menu_index`
--

LOCK TABLES `openhierarchy_menu_index` WRITE;
/*!40000 ALTER TABLE `openhierarchy_menu_index` DISABLE KEYS */;
INSERT INTO `openhierarchy_menu_index` VALUES (182,4,16,16,'16',NULL,NULL),(186,4,6,37,'se.unlogic.hierarchy.modules.menuadmin.MenuAdminModule',NULL,NULL),(188,4,25,39,'39',NULL,NULL),(190,1,76,NULL,NULL,4,NULL),(214,4,32,56,'56',NULL,NULL),(222,4,37,61,'61',NULL,NULL),(226,4,33,64,'64',NULL,NULL),(230,1,18,64,'64',NULL,NULL),(235,4,18,37,'37',NULL,NULL),(251,4,31,69,'69',NULL,NULL),(252,4,17,70,'70',NULL,NULL),(324,4,39,84,'84',NULL,NULL),(330,4,28,NULL,NULL,NULL,9),(331,4,3,NULL,NULL,NULL,10),(334,1,50,89,'89',NULL,NULL),(352,1,43,39,'18',NULL,NULL),(356,4,34,96,'96',NULL,NULL),(357,1,46,39,'19',NULL,NULL),(368,1,52,39,'24',NULL,NULL),(371,4,36,NULL,NULL,NULL,12),(376,4,38,103,'103',NULL,NULL),(382,1,56,39,'31',NULL,NULL),(383,4,35,39,'32',NULL,NULL),(386,1,59,39,'34',NULL,NULL),(394,4,8,NULL,NULL,NULL,14),(411,1,66,39,'44',NULL,NULL),(412,1,72,39,'45',NULL,NULL),(413,4,10,39,'45',NULL,NULL),(414,1,74,39,'46',NULL,NULL),(435,1,79,39,'17',NULL,NULL),(440,1,80,147,'147',NULL,NULL),(667,1,97,393,'393',NULL,NULL),(668,12,1,149,'149',NULL,NULL),(669,12,2,150,'150',NULL,NULL),(670,12,3,151,'151',NULL,NULL),(671,12,4,152,'152',NULL,NULL),(672,12,5,153,'153',NULL,NULL),(674,12,7,156,'156',NULL,NULL),(675,12,8,157,'157',NULL,NULL),(734,1,102,437,'437',NULL,NULL),(780,12,9,155,'pagesbundle12',NULL,NULL),(962,1,127,39,'47',NULL,NULL),(1026,1,135,39,'48',NULL,NULL),(1036,4,40,801,'801',NULL,NULL),(1228,1,158,1016,'1016',NULL,NULL),(2402,1,166,2320,'2320',NULL,NULL);
/*!40000 ALTER TABLE `openhierarchy_menu_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_section_attributes`
--

DROP TABLE IF EXISTS `openhierarchy_section_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_section_attributes` (
  `sectionID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`sectionID`,`name`),
  CONSTRAINT `FK_openhierarchy_section_attributes_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=232 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_section_attributes`
--

LOCK TABLES `openhierarchy_section_attributes` WRITE;
/*!40000 ALTER TABLE `openhierarchy_section_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_section_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_section_groups`
--

DROP TABLE IF EXISTS `openhierarchy_section_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_section_groups` (
  `sectionID` int(10) unsigned NOT NULL,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`sectionID`,`groupID`),
  CONSTRAINT `FK_sectiongroups_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_section_groups`
--

LOCK TABLES `openhierarchy_section_groups` WRITE;
/*!40000 ALTER TABLE `openhierarchy_section_groups` DISABLE KEYS */;
INSERT INTO `openhierarchy_section_groups` VALUES (4,8);
/*!40000 ALTER TABLE `openhierarchy_section_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_section_users`
--

DROP TABLE IF EXISTS `openhierarchy_section_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_section_users` (
  `sectionID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sectionID`,`userID`),
  CONSTRAINT `FK_sectionusers_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_section_users`
--

LOCK TABLES `openhierarchy_section_users` WRITE;
/*!40000 ALTER TABLE `openhierarchy_section_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_section_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_sections`
--

DROP TABLE IF EXISTS `openhierarchy_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_sections` (
  `sectionID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parentSectionID` int(10) unsigned DEFAULT NULL,
  `alias` varchar(255) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `anonymousAccess` tinyint(1) NOT NULL DEFAULT '0',
  `userAccess` tinyint(1) NOT NULL DEFAULT '0',
  `adminAccess` tinyint(1) NOT NULL DEFAULT '0',
  `visibleInMenu` tinyint(1) NOT NULL DEFAULT '0',
  `breadCrumb` tinyint(1) DEFAULT '1',
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `anonymousDefaultURI` varchar(255) DEFAULT NULL,
  `userDefaultURI` varchar(255) DEFAULT NULL,
  `requiredProtocol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`sectionID`),
  UNIQUE KEY `Index_2` (`parentSectionID`,`alias`),
  CONSTRAINT `FK_sections_1` FOREIGN KEY (`parentSectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=232 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_sections`
--

LOCK TABLES `openhierarchy_sections` WRITE;
/*!40000 ALTER TABLE `openhierarchy_sections` DISABLE KEYS */;
INSERT INTO `openhierarchy_sections` VALUES (1,NULL,'home',1,1,1,1,1,1,'Start','Start','/overview','/overview','HTTPS'),(4,1,'administration',1,0,0,1,1,1,'Systemadministration','Systemadministration och övervakning','/sessionadmin','/sessionadmin',NULL),(12,1,'template',0,0,0,0,0,1,'Template section','Template section',NULL,NULL,NULL);
/*!40000 ALTER TABLE `openhierarchy_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_virtual_menu_item_groups`
--

DROP TABLE IF EXISTS `openhierarchy_virtual_menu_item_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_virtual_menu_item_groups` (
  `menuItemID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`menuItemID`,`groupID`),
  CONSTRAINT `FK_virtualmenuitemgroups_1` FOREIGN KEY (`menuItemID`) REFERENCES `openhierarchy_virtual_menu_items` (`menuItemID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_virtual_menu_item_groups`
--

LOCK TABLES `openhierarchy_virtual_menu_item_groups` WRITE;
/*!40000 ALTER TABLE `openhierarchy_virtual_menu_item_groups` DISABLE KEYS */;
INSERT INTO `openhierarchy_virtual_menu_item_groups` VALUES (9,6);
/*!40000 ALTER TABLE `openhierarchy_virtual_menu_item_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_virtual_menu_item_users`
--

DROP TABLE IF EXISTS `openhierarchy_virtual_menu_item_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_virtual_menu_item_users` (
  `menuItemID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`menuItemID`,`userID`),
  CONSTRAINT `FK_virtualmenuitemusers_1` FOREIGN KEY (`menuItemID`) REFERENCES `openhierarchy_virtual_menu_items` (`menuItemID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_virtual_menu_item_users`
--

LOCK TABLES `openhierarchy_virtual_menu_item_users` WRITE;
/*!40000 ALTER TABLE `openhierarchy_virtual_menu_item_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `openhierarchy_virtual_menu_item_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `openhierarchy_virtual_menu_items`
--

DROP TABLE IF EXISTS `openhierarchy_virtual_menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `openhierarchy_virtual_menu_items` (
  `menuItemID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `itemtype` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(45) DEFAULT NULL,
  `description` text,
  `url` text,
  `anonymousAccess` tinyint(1) NOT NULL DEFAULT '0',
  `userAccess` tinyint(1) NOT NULL DEFAULT '0',
  `adminAccess` tinyint(1) NOT NULL DEFAULT '0',
  `sectionID` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`menuItemID`),
  KEY `FK_menuadmin_1` (`sectionID`),
  CONSTRAINT `FK_virtualmenuitems_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `openhierarchy_virtual_menu_items`
--

LOCK TABLES `openhierarchy_virtual_menu_items` WRITE;
/*!40000 ALTER TABLE `openhierarchy_virtual_menu_items` DISABLE KEYS */;
INSERT INTO `openhierarchy_virtual_menu_items` VALUES (9,'TITLE','Övervakning','Övervakning',NULL,0,0,1,4),(10,'TITLE','Administration','Administration',NULL,0,0,0,4),(12,'TITLE','Nordic Peak','Nordic Peak',NULL,0,0,1,4),(14,'TITLE','Administration','Administration',NULL,0,1,1,4);
/*!40000 ALTER TABLE `openhierarchy_virtual_menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_groups`
--

DROP TABLE IF EXISTS `page_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_groups` (
  `pageID` int(10) unsigned NOT NULL,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`pageID`,`groupID`),
  CONSTRAINT `FK_pagegroups_1` FOREIGN KEY (`pageID`) REFERENCES `pages` (`pageID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_groups`
--

LOCK TABLES `page_groups` WRITE;
/*!40000 ALTER TABLE `page_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_users`
--

DROP TABLE IF EXISTS `page_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_users` (
  `pageID` int(10) unsigned NOT NULL,
  `userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`pageID`,`userID`),
  CONSTRAINT `FK_pageusers_1` FOREIGN KEY (`pageID`) REFERENCES `pages` (`pageID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_users`
--

LOCK TABLES `page_users` WRITE;
/*!40000 ALTER TABLE `page_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `pageID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `text` mediumtext NOT NULL,
  `enabled` varchar(45) NOT NULL DEFAULT '',
  `visibleInMenu` tinyint(1) NOT NULL DEFAULT '0',
  `anonymousAccess` tinyint(1) NOT NULL DEFAULT '0',
  `userAccess` tinyint(1) NOT NULL DEFAULT '0',
  `adminAccess` tinyint(1) NOT NULL DEFAULT '0',
  `sectionID` int(10) unsigned NOT NULL DEFAULT '0',
  `alias` varchar(255) NOT NULL DEFAULT '',
  `breadCrumb` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`pageID`),
  UNIQUE KEY `Index_3` (`sectionID`,`alias`),
  KEY `FK_pages_1` (`sectionID`),
  CONSTRAINT `FK_pages_1` FOREIGN KEY (`sectionID`) REFERENCES `openhierarchy_sections` (`sectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 191488 kB; (`sectionID`) REFER `fkdb-system/sec';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registration_cofirmations`
--

DROP TABLE IF EXISTS `registration_cofirmations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registration_cofirmations` (
  `userID` int(10) unsigned NOT NULL,
  `linkID` varchar(36) NOT NULL,
  `host` text NOT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`),
  CONSTRAINT `FK_registrationverifications_1` FOREIGN KEY (`userID`) REFERENCES `simple_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registration_cofirmations`
--

LOCK TABLES `registration_cofirmations` WRITE;
/*!40000 ALTER TABLE `registration_cofirmations` DISABLE KEYS */;
/*!40000 ALTER TABLE `registration_cofirmations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `simple_group_attributes`
--

DROP TABLE IF EXISTS `simple_group_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `simple_group_attributes` (
  `groupID` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`groupID`,`name`),
  CONSTRAINT `FK_simple_group_attributes_1` FOREIGN KEY (`groupID`) REFERENCES `simple_groups` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `simple_group_attributes`
--

LOCK TABLES `simple_group_attributes` WRITE;
/*!40000 ALTER TABLE `simple_group_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `simple_group_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `simple_groups`
--

DROP TABLE IF EXISTS `simple_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `simple_groups` (
  `groupID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  PRIMARY KEY (`groupID`)
) ENGINE=InnoDB AUTO_INCREMENT=1412 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `simple_groups`
--

LOCK TABLES `simple_groups` WRITE;
/*!40000 ALTER TABLE `simple_groups` DISABLE KEYS */;
INSERT INTO `simple_groups` VALUES (8,'Systemadministratörer','Systemadministratörer',1),(31,'Medarbetare','Medarbetare',1);
/*!40000 ALTER TABLE `simple_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `simple_user_attributes`
--

DROP TABLE IF EXISTS `simple_user_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `simple_user_attributes` (
  `userID` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`userID`,`name`) USING BTREE,
  KEY `Index_2` (`name`),
  CONSTRAINT `FK_simple_user_attributes_1` FOREIGN KEY (`userID`) REFERENCES `simple_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `simple_user_attributes`
--

LOCK TABLES `simple_user_attributes` WRITE;
/*!40000 ALTER TABLE `simple_user_attributes` DISABLE KEYS */;
INSERT INTO `simple_user_attributes` VALUES (1,'description','Vi arbetar med...'),(1,'ical-token','1-mbhpp'),(1,'isExternal','false'),(1,'lastResume','1440511200175'),(1,'organization','Nordic Peak AB'),(1,'Personnummer','83122134234234'),(1,'phone','0706153310345'),(1,'resumeHour','16');
/*!40000 ALTER TABLE `simple_user_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `simple_user_groups`
--

DROP TABLE IF EXISTS `simple_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `simple_user_groups` (
  `userID` int(10) unsigned NOT NULL,
  `groupID` int(10) NOT NULL,
  PRIMARY KEY (`userID`,`groupID`),
  KEY `FK_usergroups_2` (`groupID`),
  CONSTRAINT `FK_usergroups_1` FOREIGN KEY (`userID`) REFERENCES `simple_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `simple_user_groups`
--

LOCK TABLES `simple_user_groups` WRITE;
/*!40000 ALTER TABLE `simple_user_groups` DISABLE KEYS */;
INSERT INTO `simple_user_groups` VALUES (1,8),(1,1385);
/*!40000 ALTER TABLE `simple_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `simple_users`
--

DROP TABLE IF EXISTS `simple_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `simple_users` (
  `userID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(40) NOT NULL,
  `password` varchar(255) NOT NULL DEFAULT '',
  `firstname` varchar(30) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastlogin` timestamp NULL DEFAULT '0000-00-00 00:00:00',
  `language` varchar(76) DEFAULT NULL,
  `preferedDesign` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `simple_users`
--

LOCK TABLES `simple_users` WRITE;
/*!40000 ALTER TABLE `simple_users` DISABLE KEYS */;
INSERT INTO `simple_users` VALUES (1,'admin@demo','1a54c17771cbf632862fae0252e504e081f86517','Admin','User','admin@demo',1,1,'2008-01-27 19:43:42','2015-10-12 06:40:57',NULL,NULL);
/*!40000 ALTER TABLE `simple_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `table_versions`
--

DROP TABLE IF EXISTS `table_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `table_versions` (
  `tableGroupName` varchar(255) NOT NULL,
  `version` int(10) unsigned NOT NULL,
  PRIMARY KEY (`tableGroupName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `table_versions`
--

LOCK TABLES `table_versions` WRITE;
/*!40000 ALTER TABLE `table_versions` DISABLE KEYS */;
INSERT INTO `table_versions` VALUES ('se.dosf.communitybase.dao.CBDAOFactory',11),('se.dosf.communitybase.modules.notifications.NotificationHandlerModule',2),('se.sundsvall.collaborationroom.modules.blog.BlogModule',3),('se.sundsvall.collaborationroom.modules.calendar.CalendarModule',1),('se.sundsvall.collaborationroom.modules.filearchive.FileArchiveModule',1),('se.sundsvall.collaborationroom.modules.link.LinkArchiveModule',1),('se.sundsvall.collaborationroom.modules.page.PageModule',4),('se.sundsvall.collaborationroom.modules.preferedsections.PreferedSectionsConnectorModule',1),('se.sundsvall.collaborationroom.modules.task.TaskModule',3),('se.unlogic.hierarchy.core.daos.implementations.mysql.MySQLCoreDAOFactory',34),('se.unlogic.hierarchy.foregroundmodules.groupproviders.SimpleGroupProviderModule',3),('se.unlogic.hierarchy.foregroundmodules.invitation.SimpleInvitationAdminModule',1),('se.unlogic.hierarchy.foregroundmodules.mailsenders.persisting.daos.mysql.MySQLMailDAOFactory',1),('se.unlogic.hierarchy.foregroundmodules.minimaluser.MinimalUserProviderModule',3),('se.unlogic.hierarchy.foregroundmodules.pagemodules.daos.annotated.AnnotatedPageDAOFactory',3),('se.unlogic.hierarchy.foregroundmodules.registration.AnnotatedConfirmationRegistrationModule',2),('se.unlogic.hierarchy.foregroundmodules.userproviders.SimpleUserProviderModule',5);
/*!40000 ALTER TABLE `table_versions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-10-12  8:52:17
