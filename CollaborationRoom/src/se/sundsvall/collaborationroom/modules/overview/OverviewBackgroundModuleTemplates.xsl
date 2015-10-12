<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/jquery.expander.min.js
		/js/overviewbackgroundmodule.js
	</xsl:variable>
	
	<xsl:variable name="links">
		/css/overviewbackgroundmodule.css
	</xsl:variable>
	
	<xsl:template match="Document">
		
		<div id="OverviewBackgroundModule" class="contentitem of-module of-no-margin of-block">
		
			<script type="text/javascript">
				toggleFavouriteURI = '<xsl:value-of select="ToggleFavouriteURI" />';
				membersModuleURI = '<xsl:value-of select="MembersModuleURI" />';
				i18nOverviewBgModule = {
					"READ_MORE": '<xsl:value-of select="$i18n.ReadMore" />',
					"HIDE_TEXT": '<xsl:value-of select="$i18n.HideText" />',
					"ADDED_FAVOURITE": '<xsl:value-of select="$i18n.AddedFavourite" />',
					"DELETED_FAVOURITE": '<xsl:value-of select="$i18n.DeletedFavourite" />',
					"ADD_AS_FAVOURITE": '<xsl:value-of select="$i18n.AddAsFavourite" />',
					"DELETE_AS_FAVOURITE": '<xsl:value-of select="$i18n.DeleteAsFavourite" />',
					"FOLLOW_SUCCESS": '<xsl:value-of select="$i18n.FollowSuccess" />',
					"UNFOLLOW_SUCCESS": '<xsl:value-of select="$i18n.UnFollowSuccess" />',
					"FOLLOW": '<xsl:value-of select="$i18n.Follow" />',
					"UNFOLLOW": '<xsl:value-of select="$i18n.UnFollow" />'
				};
			</script>
			
			<header class="of-inner-padded">
		
				<div class="of-right of-text-right">
					<ul class="of-facepile of-hide-to-sm">
						
						<xsl:apply-templates select="RandomMembers/user" />
						
						<xsl:if test="MembersModuleURI and HasManageMemberAccess">
							<li>
								<a class="of-btn of-btn-gronsta of-icon of-icon-only" href="{MembersModuleURI}#invite" data-of-tooltip="{$i18n.InviteMembers}">
									<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#plus"/></svg></i>
									<span><xsl:value-of select="$i18n.InviteMembers" /></span>
								</a>
							</li>
						</xsl:if>
					</ul>
					<ul class="of-meta-line of-float-right of-hide-to-sm">
						<li><a href="{MembersModuleURI}#members" data-of-tooltip="{$i18n.ShowMembers}"><xsl:value-of select="MembersCount" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.Members" /></a></li>
					</ul>
				</div>
				
				<figure class="of-room">
					<xsl:if test="SectionLogoURI">
						<a href="{SectionURI}"><img src="{SectionLogoURI}" alt="{name}" /></a>
					</xsl:if>
					<xsl:if test="followRoleID">
						<a href="#" class="of-btn of-btn-sm of-btn-outline of-btn-follow of-btn-inline of-btn-center of-icon">
							<span>
								<xsl:choose>
									<xsl:when test="isFollower"><xsl:value-of select="$i18n.UnFollow" /></xsl:when>
									<xsl:otherwise><xsl:value-of select="$i18n.Follow" /></xsl:otherwise>
								</xsl:choose>
							</span>
							<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#checkmark"/></svg></i>
						</a>
					</xsl:if>
				</figure>
		
				<h2 class="room-heading of-icon">
					<span>
						<xsl:if test="ToggleFavouriteURI">
							<a href="#" class="of-right of-favourite of-icon" data-of-tooltip="{$i18n.AddAsFavourite}" data-sectionid="{SectionID}">
								<xsl:if test="IsFavourite">
									<xsl:attribute name="class">of-right of-favourite of-icon favourited</xsl:attribute>
									<xsl:attribute name="data-of-tooltip"><xsl:value-of select="$i18n.DeleteAsFavourite" /></xsl:attribute>
								</xsl:if>
								<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#star"/></svg></i>
							</a>
						</xsl:if>
						<a href="{SectionURI}"><xsl:value-of select="SectionName" /></a>
						<xsl:text>&#160;</xsl:text>
					</span>
					<i>
						<svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
							<use>
								<xsl:attribute name="xlink:href">
									<xsl:choose>
										<xsl:when test="SectionAccessMode = 'CLOSED'">#lock</xsl:when>
										<xsl:when test="SectionAccessMode = 'HIDDEN'">#hidden</xsl:when>
										<xsl:otherwise>#eye</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</use>
						</svg>
					</i>
				</h2>
				<a href="#" class="of-hide-from-sm of-show-more"><xsl:value-of select="$i18n.ShowDescription" /></a>
				<div class="of-hide-to-sm of-show-more description" style="display: none">
					<xsl:value-of select="SectionDescription" />
				</div>
				
			</header>
		
		</div>
		
	</xsl:template>
	
	<xsl:template match="user">
		
		<xsl:variable name="fullName">
			<xsl:value-of select="firstname" /><xsl:text>&#160;</xsl:text><xsl:value-of select="lastname" />
		</xsl:variable>
		
		<li>
			<a class="of-profile-link" href="{/Document/ShowProfileURI}/{userID}">
				<figure class="of-profile of-figure-sm">
					<xsl:if test="/Document/ProfileImageURI">
						<img alt="{$fullName}" src="{/Document/ProfileImageURI}/{userID}" data-of-tooltip="{$fullName}" />
					</xsl:if>
				</figure>
			</a>
		</li>

	</xsl:template>
	
</xsl:stylesheet>