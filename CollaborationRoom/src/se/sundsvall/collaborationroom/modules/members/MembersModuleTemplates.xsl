<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:include href="classpath://se/unlogic/hierarchy/core/utils/xsl/Common.xsl"/>
	<xsl:include href="classpath://se/dosf/communitybase/utils/xsl/Common.xsl"/>

	<xsl:variable name="scriptPath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/js</xsl:variable>
	<xsl:variable name="imagePath"><xsl:value-of select="/Document/requestinfo/contextpath" />/static/f/<xsl:value-of select="/Document/module/sectionID" />/<xsl:value-of select="/Document/module/moduleID" />/pics</xsl:variable>

	<xsl:variable name="globalscripts">
		/jquery/jquery.js
	</xsl:variable>

	<xsl:variable name="scripts">
		/js/membersmodule.js
	</xsl:variable>

	<xsl:variable name="links">
		/css/membersmodule.css
	</xsl:variable>

	<xsl:template match="Document">
		
		<div id="MembersModule" class="contentitem of-module of-block">
			
			<xsl:apply-templates select="ListMembers" />
			
			<script type="text/javascript">
				membersModuleAlias = '<xsl:value-of select="/Document/requestinfo/currentURI" />/<xsl:value-of select="/Document/module/alias" />';
				i18nMembersModule = {
					"NEW_ROLE_MESSAGE": '<xsl:value-of select="$i18n.NewRoleMessage" />',
					"MEMBER_DELETED_MESSAGE": '<xsl:value-of select="$i18n.MemberDeletedMessage" />',
					"NO_USERS_FOUND": '<xsl:value-of select="$i18n.NoUsersFound" />',
					"NO_USERS_FOUND_EXTERNAL_HINT": '<xsl:value-of select="$i18n.NoUsersFoundExternalHint" />',
					"EXISTING_USER_MESSAGE": '<xsl:value-of select="$i18n.ExistingUserMessage" />',
					"EXISTING_ROLE_MESSAGE_PART1": '<xsl:value-of select="$i18n.ExistingRoleMessage.Part1" />',
					"EXISTING_ROLE_MESSAGE_PART2": '<xsl:value-of select="$i18n.ExistingRoleMessage.Part2" />',
					"EXISTING_INVITATION_MESSAGE": '<xsl:value-of select="$i18n.ExistingInvitationMessage" />',
					"EXISTING_ROLE_INVITATION_MESSAGE_PART1": '<xsl:value-of select="$i18n.ExistingRoleInvitationMessage.Part1" />',
					"EXISTING_ROLE_INVITATION_MESSAGE_PART2": '<xsl:value-of select="$i18n.ExistingRoleInvitationMessage.Part2" />',
					"INVITATION_RESENT": '<xsl:value-of select="$i18n.InvitationResent" />',
					"NO_MANAGE_MEMBER_ROLE": '<xsl:value-of select="$i18n.NoManageMemberRole" />',
					"USERS": '<xsl:value-of select="$i18n.users" />',
					"NO_GROUPS_FOUND" : '<xsl:value-of select="$i18n.NoGroupsFound" />'
				};
			</script>
			
		</div>
		
	</xsl:template>
	
	<xsl:template match="ListMembers">
		
		<header class="of-inner-padded-rl of-inner-padded-tb-half of-header-border">
			<xsl:if test="/Document/hasManageAccess">
				<div class="of-right">
					<a data-of-toggler="invite" href="#" class="of-btn of-btn-gronsta of-btn-xs of-btn-inline of-icon">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#plus"/></svg></i>
						<span><xsl:value-of select="$i18n.InviteUsers" /></span>
					</a>
				</div>
			</xsl:if>
			<h2><xsl:value-of select="/Document/module/name" /></h2>
		</header>
		
		<xsl:if test="/Document/hasManageAccess">
			<div class="of-border-bottom of-hidden" data-of-toggled="invite">
	
				<div class="of-tabs">
	
					<div class="of-tabs-wrap">
	
						<div class="of-tabs-wrap-inner">
	
							<ul>
								<li><a href="#tabs-1"><xsl:value-of select="$i18n.InternalUsers" /></a></li>
								<li><a href="#tabs-2"><xsl:value-of select="$i18n.ExternalUsers" /></a></li>
								<li><a href="#tabs-3"><xsl:value-of select="$i18n.Group" /></a></li>
							</ul>
	
						</div>
	
					</div>
	
					<div id="tabs-1" class="of-inner-padded">
						
						<label>
							<span id="external-title"><xsl:value-of select="$i18n.InviteInternalUsers" /></span>
							<div class="of-select-multiple">
								<input id="search-user" type="text" name="searchUser" />
								<div  class="of-select-multiple">
									<article id="search-user-result">
										<ul />
									</article>						
								</div>
							</div>
							<span class="description"><xsl:value-of select="$i18n.SearchByName" /></span>
						</label>
	
						<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=addmember" method="post">
	
							<ul id="search-user-list" class="of-participant-list of-inner-padded-t of-inner-padded-b-half of-hidden">
								<li class="of-placeholder">
									<xsl:call-template name="createHiddenField">
										<xsl:with-param name="name" select="'userID'" />
										<xsl:with-param name="value" select="''" />
									</xsl:call-template>
									<div class="of-right">
										<a class="of-icon of-icon-only remove-item" href="#">
											<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#close"></use></svg></i>
											<span><xsl:value-of select="$i18n.DeleteFormList.Part1" /><xsl:text>&#160;</xsl:text><u data-of-placeholder="name"></u><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.DeleteFormList.Part2" /></span>
										</a>
									</div>
									<figure class="of-profile of-figure-sm">
										<xsl:if test="/Document/ProfileImageAlias">
											<img alt="" data-profileimagealias="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}" />
										</xsl:if>
									</figure>
									<header class="of-inline">
										<u data-of-placeholder="name"></u>
										<ul class="of-meta-line">
											<li />
										</ul>
										<xsl:call-template name="createRolesDropdown">
											<xsl:with-param name="roles" select="AllowedRoles/Role" />
										</xsl:call-template>
									</header>
								</li>
							</ul>
		
							<div class="of-text-right">
								<button id="invite-user-button" type="submit" class="of-btn of-btn-inline of-btn-gronsta of-hidden"><xsl:value-of select="$i18n.Add" /></button>
							</div>
	
						</form>
	
					</div>
	
					<div id="tabs-2" class="of-inner-padded">
						
						<label class="of-icon of-relative">
							<xsl:value-of select="$i18n.InviteExternalUser" />
							<input id="invite-external" type="email" name="external" />
							<span class="description"><xsl:value-of select="$i18n.InviteByEmail" /></span>
						</label>
						
						<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=addinvitations" method="post">
	
							<ul id="invite-external-list" class="of-participant-list of-inner-padded-t of-inner-padded-b-half of-hidden">
								<li class="of-placeholder">
									<xsl:call-template name="createHiddenField">
										<xsl:with-param name="name" select="'email'" />
										<xsl:with-param name="value" select="''" />
									</xsl:call-template>
									<div class="of-right">
										<a class="of-icon of-icon-only remove-item" href="#" aria-label="{$i18n.Delete}">
											<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#close"></use></svg></i>
											<span><xsl:value-of select="$i18n.DeleteFormList.Part1" /><xsl:text>&#160;</xsl:text><u data-of-placeholder="email"></u><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.DeleteFormList.Part2" /></span>
										</a>
									</div>
									<figure class="of-profile of-figure-sm">
										<xsl:if test="/Document/ProfileImageAlias">
											<img alt="" data-profileimagealias="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}" />
										</xsl:if>
									</figure>
									<header class="of-inline">
										<u data-of-placeholder="email"></u>
										<ul class="of-meta-line">
										</ul>
										<xsl:call-template name="createRolesDropdown">
											<xsl:with-param name="roles" select="AllowedRoles/Role" />
										</xsl:call-template>
									</header>
								</li>
							</ul>
						
							<div class="of-text-right">
								<button id="invite-external-button" type="submit" class="of-btn of-btn-inline of-btn-gronsta of-hidden">Skicka inbjudan</button>
							</div>
							
						</form>
	
					</div>
	
					<div id="tabs-3" class="of-inner-padded">
						
						<label class="of-icon of-relative">
							<xsl:value-of select="$i18n.InviteGroup" />
							<div class="of-select-multiple">
								<input id="search-group" type="text" name="searchUser" />
								<div  class="of-select-multiple">
									<article id="search-group-result">
										<ul />
									</article>
								</div>
							</div>
							<span class="description"><xsl:value-of select="$i18n.SearchGroupByName" /></span>
						</label>						
							
						<form action="{/Document/requestinfo/currentURI}/{/Document/module/alias}?method=addmember" method="post">
	
							<ul id="search-group-list" class="of-participant-list of-inner-padded-t of-inner-padded-b-half of-hidden">
								<li class="of-placeholder">
									<xsl:call-template name="createHiddenField">
										<xsl:with-param name="name" select="'userID'" />
										<xsl:with-param name="value" select="''" />
									</xsl:call-template>
									<div class="of-right">
										<a class="of-icon of-icon-only remove-item" href="#">
											<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#close"></use></svg></i>
											<span><xsl:value-of select="$i18n.DeleteFormList.Part1" /><xsl:text>&#160;</xsl:text><u data-of-placeholder="name"></u><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.DeleteFormList.Part2" /></span>
										</a>
									</div>
									<figure class="of-profile of-figure-sm">
										<xsl:if test="/Document/ProfileImageAlias">
											<img alt="" data-profileimagealias="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}" />
										</xsl:if>
									</figure>
									<header class="of-inline">
										<u data-of-placeholder="name"></u>
										<ul class="of-meta-line">
											<li />
										</ul>
										<xsl:call-template name="createRolesDropdown">
											<xsl:with-param name="roles" select="AllowedRoles/Role" />
										</xsl:call-template>
									</header>
								</li>
							</ul>
							
							<div class="of-text-right">
									<button id="invite-group-button" type="submit" class="of-btn of-btn-inline of-btn-gronsta of-hidden"><xsl:value-of select="$i18n.Add" /></button>
							</div>							
							
						</form>						
	
					</div>
	
				</div>
	
			</div>
		
		</xsl:if>
		
		<div class="of-inner-padded">

			<a name="members" />

			<h3><xsl:value-of select="$i18n.AllMembers" /></h3>
			
			<ul id="member-list" class="of-participant-list of-inner-padded-b">
				
				<xsl:choose>
					<xsl:when test="Members/user">
						<xsl:apply-templates select="Members/user" mode="member" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$i18n.NoMembers" />
					</xsl:otherwise>
				</xsl:choose>
				
			</ul>

			<a name="invitations" />

			<h3><xsl:value-of select="$i18n.InvitedUsers" /></h3>
			
			<ul id="invitations-list" class="of-participant-list of-inner-padded-b">
			
				<xsl:choose>
					<xsl:when test="Invitations/Invitation">
						<xsl:apply-templates select="Invitations/Invitation" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$i18n.NoInvitedUsers" />
					</xsl:otherwise>
				</xsl:choose>
				
			</ul>
				
		</div>
		
	</xsl:template>
	
	<xsl:template match="user" mode="member">
		
		<xsl:variable name="fullName">
			<xsl:call-template name="printUser">
				<xsl:with-param name="user" select="." />
			</xsl:call-template>
		</xsl:variable>
		
		<li data-userid="{userID}" data-fullname="{$fullName}">
			<xsl:if test="/Document/hasManageAccess or userID = /Document/user/userID">
				<div class="of-right">
					<a aria-label="{$i18n.DeleteFromRoom.Part1} {$fullName} {$i18n.DeleteFromRoom.Part2}" href="#" class="of-icon of-icon-only delete-btn" data-confirm="{$i18n.DeleteMemberConfirm.Part1} {$fullName} {$i18n.DeleteMemberConfirm.Part2}?">
						<xsl:if test="userID = /Document/user/userID">
							<xsl:attribute name="data-confirm"><xsl:value-of select="$i18n.DeleteYourselfConfirm" />?</xsl:attribute>
						</xsl:if>
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#trash"/></svg></i>
						<span><xsl:value-of select="$i18n.DeleteFromRoom.Part1" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$fullName" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.DeleteFromRoom.Part2" /></span>
					</a>
				</div>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="/Document/ShowProfileAlias">

					<figure class="of-profile of-figure-sm">
						<a href="{/Document/requestinfo/contextpath}{/Document/ShowProfileAlias}/{userID}">
							<img alt="{$fullName}" src="{/Document/requestinfo/contextpath}{/Document/ProfileImageAlias}/{userID}" />
						</a>
					</figure>
					
				</xsl:when>
				<xsl:otherwise>
					<figure class="of-profile of-figure-sm" />
				</xsl:otherwise>
			</xsl:choose>
			
			<header class="of-inline">
				<xsl:value-of select="$fullName" />
				<ul class="of-meta-line">
					<xsl:if test="Attributes/Attribute[Name='organization']">
						<li><xsl:value-of select="Attributes/Attribute[Name='organization']/Value" /></li>
					</xsl:if>
				</ul>
				<xsl:call-template name="createRolesDropdown">
					<xsl:with-param name="roles" select="../../AllowedRoles/Role" />
					<xsl:with-param name="user" select="." />
				</xsl:call-template>
			</header>
		</li>
		
	</xsl:template>
	
	<xsl:template match="Invitation">
		
		<li data-invitationid="{invitationID}" data-email="{email}">
			<xsl:if test="/Document/hasManageAccess">
				<div class="of-right">
					<a aria-label="{$i18n.DeleteInvitation.Part1} {email} {$i18n.DeleteInvitation.Part2}" href="#" class="of-icon of-icon-only delete-btn" data-confirm="{$i18n.DeleteInvitationConfirm}: {email}?">
						<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#trash"/></svg></i>
						<span><xsl:value-of select="$i18n.DeleteInvitation.Part1" /><xsl:text>&#160;</xsl:text><xsl:value-of select="email" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.DeleteInvitation.Part2" /></span>
					</a>
				</div>
			</xsl:if>
			<figure class="of-profile of-figure-sm" />
			<header class="of-inline">
				<xsl:value-of select="email" />
				<ul class="of-meta-line">
					<xsl:if test="lastSent">
						<li>
							<xsl:value-of select="$i18n.InvitationLastSent" /><xsl:text>&#160;</xsl:text><span class="lastSent"><xsl:value-of select="lastSent" /></span>
						</li>
					</xsl:if>
					<xsl:if test="sendCount > 1">
						<li>
							<xsl:value-of select="$i18n.InvitationSentCount.Part1" /><xsl:text>&#160;</xsl:text><span class="sendCount"><xsl:value-of select="sendCount" /></span><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n.InvitationSentCount.Part2" />
						</li>
					</xsl:if>	
				</ul>
				
				<xsl:variable name="roleID" select="sectionInvitations/SectionInvitation[sectionID = /Document/section/sectionID]/roleID" />
				
				<xsl:call-template name="createInvitationRolesDropdown">
					<xsl:with-param name="roles" select="../../AllowedRoles/Role" />
					<xsl:with-param name="roleID" select="$roleID" />
				</xsl:call-template>
				<xsl:if test="/Document/hasManageAccess">
					<xsl:text>&#160;</xsl:text>
					<button type="button"><xsl:value-of select="$i18n.ResendInvitation" /></button>
				</xsl:if>
			</header>
		</li>
		
	</xsl:template>
	
	<xsl:template name="createRolesDropdown">
		
		<xsl:param name="roles" />
		<xsl:param name="user" select="null" />
		
		<select name="role" title="{$i18n.ChooseUserRole}">
			<xsl:if test="not(/Document/hasManageAccess)">
				<xsl:attribute name="disabled">disabled</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="$roles">
				
				<xsl:variable name="roleID" select="roleID" />
				<xsl:variable name="groupID" select="group/groupID" />
				
				<option value="{$roleID}">
					<xsl:if test="$user/groups/group[groupID = $groupID]">
						<xsl:attribute name="selected" />
					</xsl:if>
					<xsl:value-of select="name" />				
				</option>
				
			</xsl:for-each>
			
		</select>
		
	</xsl:template>
	
	<xsl:template name="createInvitationRolesDropdown">
		
		<xsl:param name="roles" />
		<xsl:param name="roleID" />
		
		<select name="role" title="{$i18n.ChooseInvitationRole}">
			<xsl:if test="not(/Document/hasManageAccess)">
				<xsl:attribute name="disabled">disabled</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="$roles">
				
				<option value="{roleID}">
					<xsl:if test="roleID = $roleID">
						<xsl:attribute name="selected" />
					</xsl:if>
					<xsl:value-of select="name" />				
				</option>
				
			</xsl:for-each>
			
		</select>
		
	</xsl:template>
	
	<xsl:template name="printUser">
		
		<xsl:param name="user" />
		
		<xsl:choose>
			<xsl:when test="$user"><xsl:value-of select="$user/firstname" /><xsl:text>&#160;</xsl:text><xsl:value-of select="$user/lastname" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$i18n.DeletedUser" /></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="validationError">
		
		<xsl:if test="fieldName and validationErrorType">
			<p class="error">
				<xsl:choose>
					<xsl:when test="validationErrorType='RequiredField'">
						<xsl:value-of select="$i18n.validationError.RequiredField" />
					</xsl:when>
					<xsl:when test="validationErrorType='InvalidFormat'">
						<xsl:value-of select="$i18n.validationError.InvalidFormat" />
					</xsl:when>
					<xsl:when test="validationErrorType='TooShort'">
						<xsl:value-of select="$i18n.validationError.TooShort" />
					</xsl:when>
					<xsl:when test="validationErrorType='TooLong'">
						<xsl:value-of select="$i18n.validationError.TooLong" />
					</xsl:when>
					<xsl:when test="validationErrorType='Other'">
						<xsl:value-of select="$i18n.validationError.Other" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$i18n.validationError.unknownValidationErrorType" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>&#x20;</xsl:text>
				<xsl:choose>
					<xsl:when test="fieldName = ''">
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="fieldName" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>!</xsl:text>
				
			</p>
		</xsl:if>
		<xsl:if test="messageKey">
			
				<xsl:choose>
					<xsl:when test="messageKey=''">
						
					</xsl:when>
					<xsl:otherwise>
						<p class="error"><xsl:value-of select="$i18n.validationError.unknownMessageKey" />!</p>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:if>
		<xsl:apply-templates select="message" />
		
	</xsl:template>
	
</xsl:stylesheet>