var membersModuleAlias;
var i18nMembersModule = {
	"NEW_ROLE_MESSAGE": 'New role set to',
	"MEMBER_DELETED_MESSAGE": "deleted from room",
	"NO_USERS_FOUND": "No users matched the search",
	"NO_USERS_FOUND_EXTERNAL_HINT": "To add an external member use the 'external' tab",
	"EXISTING_USER_MESSAGE": "The user already has a user account and will have access to collaboration room directly",
	"EXISTING_ROLE_MESSAGE_PART1": "The user already has the role",
	"EXISTING_ROLE_MESSAGE_PART2": "in this collaborative room. The invitation will be ignored.",
	"EXISTING_INVITATION_MESSAGE": "There is already an invitation to another collaboration rooms for the e-mail address. The user will get access to collaboration room as soon as he / she registered for an account.",
	"EXISTING_ROLE_INVITATION_MESSAGE_PART1": "There is already an invitation with this e-mail",
	"EXISTING_ROLE_INVITATION_MESSAGE_PART2": "in this collaborative room. The invitation will be ignored.",
	"INVITATION_RESENT": "Invitation resent to",
	"NO_MANAGE_MEMBER_ROLE": "There must be at least one administrator",
	"USERS" : "users",
	"NO_GROUPS_FOUND" : "No groups matched the search"
};
var MIN_SEARCH_LENGTH = 3;

$(document).ready(function() {
	
	var $members = $("#member-list li");
	
	var addedUserIDs = new Array();
	
	var addedGroupUserIDs = new Array();
	
	$members.each(function() {
		addedUserIDs.push($(this).data("userid"));
		addedGroupUserIDs.push($(this).data("userid"));
	});
	
	$members.find("select").each(function() {
		$(this).data("currentrole", $(this).find('option:selected').val());
	});
	
	$members.find("select").on("change", function() {
		
		var $this = $(this);
		
		var $selectedOption = $this.find('option:selected');

		var userID = $selectedOption.closest("li").data("userid");
		var roleID = $selectedOption.val();
		
		$.ajax({
			type: "GET",
			cache: false,
			url: membersModuleAlias + "/updaterole/" + userID + "/" + roleID,
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				if(response.UpdateSuccess) {
					
					$this.data("currentrole", roleID);
					
					new OF_Notification(i18nMembersModule.NEW_ROLE_MESSAGE + " " + $selectedOption.text());
					
				} else if(response.NoManageMemberRole) {
					
					$this.val($this.data("currentrole"));
					
					new OF_Notification(i18nMembersModule.NO_MANAGE_MEMBER_ROLE, "error");
				
					return false;
				}
				
			}
		});
	
	});
	
	$members.find("a.delete-btn").on("click", function(e) {
		
		e.preventDefault();
		
		var $this = $(this);
		
		if(confirm($this.data("confirm"))) {
			
			var $user = $this.closest("li");
			
			var userID = $user.data("userid");
			
			$.ajax({
				type: "GET",
				cache: false,
				url: membersModuleAlias + "/deletemember/" + userID,
				dataType: "json",
				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
				error: function (xhr, ajaxOptions, thrownError) {  },
				success: function(response) {
					
					if(response.DeleteSuccess) {
						
						new OF_Notification($user.data("fullname") + " " + i18nMembersModule.MEMBER_DELETED_MESSAGE);
						$user.fadeOut("fast", function() {
							
							$(this).remove();
							
							if(response.RedirectUser) {
							
								window.location = response.RedirectUser;
								
								return;
							}
							
						});
						
						addedUserIDs.splice(addedUserIDs.indexOf(userID));
						addedGroupUserIDs.splice(addedUserIDs.indexOf(userID));
						
					} else if(response.NoManageMemberRole) {
						
						new OF_Notification(i18nMembersModule.NO_MANAGE_MEMBER_ROLE, "error");
					}
					
				}
			});
			
		}
		
	});
	
	var $invitations = $("#invitations-list li");
	
	$invitations.find("select").on("change", function() {
		
		var $this = $(this);
		
		var $selectedOption = $this.find('option:selected');

		var invitationID = $selectedOption.closest("li").data("invitationid");
		var roleID = $selectedOption.val();
		
		$.ajax({
			type: "GET",
			cache: false,
			url: membersModuleAlias + "/updateinvitationrole/" + invitationID + "/" + roleID,
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				if(response.UpdateSuccess) {
					new OF_Notification(i18nMembersModule.NEW_ROLE_MESSAGE + " " + $selectedOption.text());
				}
				
			}
		});
	
	});
	
	$invitations.find("a.delete-btn").on("click", function(e) {
		
		e.preventDefault();
		
		var $this = $(this);
		
		if(confirm($this.data("confirm"))) {
			
			var $invitation = $this.closest("li");
			
			$.ajax({
				type: "GET",
				cache: false,
				url: membersModuleAlias + "/deleteinvitation/" + $invitation.data("invitationid"),
				dataType: "json",
				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
				error: function (xhr, ajaxOptions, thrownError) {  },
				success: function(response) {
					
					if(response.DeleteSuccess) {
						
						new OF_Notification($invitation.data("email") + " " + i18nMembersModule.MEMBER_DELETED_MESSAGE);
						$invitation.fadeOut("fast", function() {
							$(this).remove();
						});
						
					}
					
				}
			});
			
		}
		
	});
	
	$invitations.find("button").on("click", function(e) {
		
		var $btn = $(this);
		
		var $invitation = $(this).closest("li");
		
		$.ajax({
			type: "GET",
			cache: false,
			url: membersModuleAlias + "/resendinvitation/" + $invitation.data("invitationid"),
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				if(response.SendSuccess) {
					
					new OF_Notification(i18nMembersModule.INVITATION_RESENT + " " + $invitation.data("email"));
					$invitation.find("span.lastSent").text(response.SendSuccess.lastSent);
					$invitation.find("span.sendCount").text(response.SendSuccess.sendCount);
					
				}
				
			}
		});
		
	});
	
	$("#search-user").keyup(function (e) {
		
		var keyCode = e.which;
		
		var $searchResultList = $("#search-user-result").find("ul");
		
		var $current = $searchResultList.find("li.current");
		
		if(keyCode == 13) {

			selectUser($current);
			
		} else if(keyCode == 38 || keyCode == 40) {
			
			var $nextElement;
			
			if(keyCode == 38) {
				$nextElement = $current.length == 0 ? $searchResultList.find("li.notmember").last() : $current.prevAll(".notmember").first();
			} else {
				$nextElement = $current.length == 0 ? $searchResultList.find("li.notmember").first() : $current.nextAll(".notmember").first();
			}

			if($nextElement.hasClass("child")) {
				$current.removeClass("current");
				$nextElement.addClass("current");
			}
			
		} else {
			
			searchUser();
			
		}
		
    }).bind('focus', function() {
    	$(this).addClass('focus');
    	searchUser();
	}).bind("blur", function() {
		$(this).removeClass('focus');
	});
	
	$("#search-group").keyup(function (e) {
		
		var keyCode = e.which;
		
		var $searchResultList = $("#search-group-result").find("ul");
		
		var $current = $searchResultList.find("li.current");
		
		if(keyCode == 13) {

			selectGroup($current);
			
		} else if(keyCode == 38 || keyCode == 40) {
			
			var $nextElement;
			
			if(keyCode == 38) {
				$nextElement = $current.length == 0 ? $searchResultList.find("li.notmember").last() : $current.prevAll(".notmember").first();
			} else {
				$nextElement = $current.length == 0 ? $searchResultList.find("li.notmember").first() : $current.nextAll(".notmember").first();
			}

			if($nextElement.hasClass("child")) {
				$current.removeClass("current");
				$nextElement.addClass("current");
			}
			
		} else {
			
			searchGroup();
		}
		
    }).bind('focus', function() {
    	$(this).addClass('focus');
    	searchUser();
	}).bind("blur", function() {
		$(this).removeClass('focus');
	});	
	
	$(document).on("click", function(e) {
		
		if($(e.target).closest(".of-select-multiple").length == 0) {
			$("#search-user-result").hide();
			$("#search-group-result").hide();
		}
		
	});
	
	var addedEmails = new Array();
	
	$("#invite-external").keyup(function (e) {
		
		var $this = $(this);
		
		var keyCode = e.which;
		
		if (keyCode == 13 && $.trim($this.val()).length > 0) {

			e.preventDefault();
			
			var $inviteExternalList = $("#invite-external-list");
			var $template = $inviteExternalList.find("li.of-placeholder");
			var $submitButton = $("#invite-external-button");
			
            var invalidEmails = "";
            
            var emails = $this.val().split(",");
            
            $.each(emails, function(i, email) {
            	
            	email = $.trim(email);
            	
            	if(isValidEmail(email)) {
            		
            		if($.inArray(email, addedEmails) == -1) {
            		
	            		$.ajax({
	        				
	        				cache: false,
	        				url: membersModuleAlias + "/checkemail/" + "?email=" + email,
	        				dataType: "json",
	        				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
	        				error: function (xhr, ajaxOptions, thrownError) { },
	        				success: function(response) {
	        					
	        					var $invite = $template.clone();
	        					
	        					$invite.find("input[type='hidden']").val(email);
	        					$invite.find("u[data-of-placeholder='email']").replaceWith(email);
	        					$invite.find("a").click(function() {
	        						
	        						$invite.fadeOut("fast", function() {
	
	        							$(this).remove();
	        							
	        							addedEmails.splice(addedEmails.indexOf(email));
	        							
	        							if($inviteExternalList.find("li:not(.of-placeholder)").length == 0) {
	        								$submitButton.addClass("of-hidden");
	        								$inviteExternalList.addClass("of-hidden");
	        							}
	        							
	        						});
	        						
	        					});
	        					
	        					var $select = $invite.find("select");
	        					$select.attr("name", "role_" + email);
	        					var $profileImage = $invite.find(".of-profile img");
	        					
	        					if(response.ExistingUser) {
	        						
	        						if(response.ExistingUser.Role) {
	        							$invite.find(".of-meta-line").append("<li class='error'>" + response.ExistingUser.fullName + " " + i18nMembersModule.EXISTING_ROLE_MESSAGE_PART1 + " \"" + response.ExistingUser.Role.name + "\" " + i18nMembersModule.EXISTING_ROLE_MESSAGE_PART2 + "</li>")
	        							$select.val(response.ExistingUser.Role.roleID);
	        							$select.attr("disabled", "disabled");
	        						} else {
	        							$invite.find(".of-meta-line").append("<li class='success'>" + response.ExistingUser.fullName + " " + i18nMembersModule.EXISTING_USER_MESSAGE + "</li>");
	        						}
	        						
	        						$profileImage.attr("src", $profileImage.data("profileimagealias") + "/" + response.ExistingUser.userID);
	        						
	        					} else if(response.ExistingInvitation) {
	        						
	        						if(response.ExistingInvitation.Role) {
	        							$invite.find(".of-meta-line").append("<li class='error'>" + i18nMembersModule.EXISTING_ROLE_INVITATION_MESSAGE_PART1 + " \"" + response.ExistingInvitation.email + "\" " + i18nMembersModule.EXISTING_ROLE_INVITATION_MESSAGE_PART2 + "</li>")
	        							$select.val(response.ExistingInvitation.Role.roleID);
	        							$select.attr("disabled", "disabled");
	        						} else {
	        							$invite.find(".of-meta-line").append("<li class='success'>" + i18nMembersModule.EXISTING_INVITATION_MESSAGE + "</li>");
	        						}
	        						
	        						$profileImage.remove();
	        						
	        					}
	        					
	        					$invite.find("select").attr("name", "role_" + email);
	        					$invite.removeClass("of-placeholder");
	        					$inviteExternalList.append($invite);
	        					
	        					$inviteExternalList.removeClass("of-hidden");
	        					$submitButton.removeClass("of-hidden");
	
	        					addedEmails.push(email);
	        					
	        				}
	        				
	        			});
            		
            		}
            		
            	} else {

            		invalidEmails = invalidEmails + (invalidEmails != "" ? "," : "") + email;
            	}
            	
            });
            
            $this.val(invalidEmails);
            
		}
		
	});
	
	var searchUser = function() {
		
		var searchStr = $('#search-user').val();

		var $searchWrapper = $("#search-user-result");
		var $searchResultList = $searchWrapper.find("ul");
		
		if(searchStr != "" && searchStr.length >= MIN_SEARCH_LENGTH) {
			
			$.ajax({
				
				cache: false,
				url: membersModuleAlias + "/searchuser/" + "?q=" + searchStr,
				dataType: "json",
				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
				error: function (xhr, ajaxOptions, thrownError) { },
				success: function(response) {

					$searchResultList.html("");
					
					if(response.hitCount > 0) {
					
						$.each(response.hits, function(key, user) {
				        	
							var $user = $("<li class='child' data-userid='" + user.userID + "' style='display: list-item;'>" + user.fullName + "</li>")

							if($.inArray(user.userID, addedUserIDs) == -1) {
								
								$user.hover(function() {
									$(this).addClass("current");
								}, function() {
									$(this).removeClass("current");
								});
								
								$user.click(function() {
									selectUser($user);
								});
								
								$user.addClass("notmember");
								
							} else {
								$user.addClass("selected");
							}
							
							$searchResultList.append($user);
							
						});
					
						$searchResultList.find("li:not(.selected)").first().addClass("current");
						
					} else {
						
						if(searchStr.indexOf("@") >= 0) {
							$searchResultList.append("<li class='error'>" + i18nMembersModule.NO_USERS_FOUND + " \"" + searchStr + "\". " + i18nMembersModule.NO_USERS_FOUND_EXTERNAL_HINT + ".</li>");
						} else {
							$searchResultList.append("<li class='error'>" + i18nMembersModule.NO_USERS_FOUND + " \"" + searchStr + "\"" +  "</li>");
						}
						
					}
					
					$searchWrapper.show();
					
				}
				
			});
			
	        
	    } else {
	    	
	    	$searchResultList.html("");
	    	$searchWrapper.hide();
	 
	    }
		
	};
	
	var searchGroup = function() {
		
		var searchStr = $('#search-group').val();

		var $searchWrapper = $("#search-group-result");
		var $searchResultList = $searchWrapper.find("ul");
		
		if(searchStr != "" && searchStr.length >= MIN_SEARCH_LENGTH) {
			
			$.ajax({
				
				cache: false,
				url: membersModuleAlias + "/searchgroup/" + "?q=" + searchStr,
				dataType: "json",
				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
				error: function (xhr, ajaxOptions, thrownError) { },
				success: function(response) {

					$searchResultList.html("");
					
					if(response.hitCount > 0) {
					
						$.each(response.hits, function(key, group) {
				        	
							var $group = $("<li class='child' data-groupid='" + group.groupID + "' style='display: list-item;'>" + group.name + " (" + group.userCount + " " + i18nMembersModule.USERS + ")</li>")

							$group.hover(function() {
								$(this).addClass("current");
							}, function() {
								$(this).removeClass("current");
							});
							
							$group.click(function() {
								selectGroup($group);
							});
							
							$group.addClass("notmember");
							
							$searchResultList.append($group);
							
						});
					
						$searchResultList.find("li:not(.selected)").first().addClass("current");
						
					} else {
						
						$searchResultList.append("<li class='error'>" + i18nMembersModule.NO_GROUPS_FOUND + " \"" + searchStr + "\"" +  "</li>");
						
					}
					
					$searchWrapper.show();
					
				}
				
			});
			
	        
	    } else {
	    	
	    	$searchResultList.html("");
	    	$searchWrapper.hide();
	 
	    }
		
	};	
	
	var selectUser = function($userElement) {
		
		if($userElement.length > 0 && !$userElement.hasClass("selected")) {
			
			var userID = $userElement.data("userid");
			
			var $userList = $("#search-user-list");
			
			var $template = $userList.find(".of-placeholder");
			
			var $newUser = $template.clone();
			
			var $submitButton = $("#invite-user-button");
			
			$newUser.find("input[type='hidden']").val(userID);
			$newUser.find("u[data-of-placeholder='name']").replaceWith($userElement.text());
			var $profileImage = $newUser.find(".of-profile img");
			$profileImage.attr("src", $profileImage.data("profileimagealias") + "/" + userID);
			$newUser.find("a").click(function() {
				
				$newUser.fadeOut("fast", function() {

					$(this).remove();
					addedUserIDs.splice(addedUserIDs.indexOf(userID));
					
					if($userList.find("li:not(.of-placeholder)").length == 0) {
						$submitButton.addClass("of-hidden");
						$userList.addClass("of-hidden");
					}
					
				});
				
			});
			
			$newUser.find("select").attr("name", "role_" + userID);
			$newUser.removeClass("of-placeholder");
			$userList.append($newUser);
			
			$userList.removeClass("of-hidden");
			$submitButton.removeClass("of-hidden");
			
			addedUserIDs.push(userID);
			
			$("#search-user-result").hide();
			$('#search-user').trigger("blur").val("");
			
		}
		
	};
	
	var selectGroup = function($groupElement) {
		
		if($groupElement.length > 0 && !$groupElement.hasClass("selected")) {
			
			var groupID = $groupElement.data("groupid");
			
			$.ajax({
				
				cache: false,
				url: membersModuleAlias + "/getgroupusers/" + "?g=" + groupID,
				dataType: "json",
				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
				error: function (xhr, ajaxOptions, thrownError) { },
				success: function(response) {

					if(response.hitCount > 0) {
						
						var $userList = $("#search-group-list");
						
						var $template = $userList.find(".of-placeholder");
						
						var $submitButton = $("#invite-group-button");
						
						$.each(response.hits, function(key, user) {
				        	
							if($.inArray(user.userID, addedGroupUserIDs) == -1) {
								
								var $newUser = $template.clone();
								
								$newUser.find("input[type='hidden']").val(user.userID);
								$newUser.find("u[data-of-placeholder='name']").replaceWith(user.fullName);
								var $profileImage = $newUser.find(".of-profile img");
								$profileImage.attr("src", $profileImage.data("profileimagealias") + "/" + user.userID);
								$newUser.find("a").click(function() {
									
									$newUser.fadeOut("fast", function() {

										$(this).remove();
										addedGroupUserIDs.splice(addedGroupUserIDs.indexOf(user.userID));
										
										if($userList.find("li:not(.of-placeholder)").length == 0) {
											$submitButton.addClass("of-hidden");
											$userList.addClass("of-hidden");
										}
										
									});
									
								});
								
								$newUser.find("select").attr("name", "role_" + user.userID);
								$newUser.removeClass("of-placeholder");
								$userList.append($newUser);	
								
								addedGroupUserIDs.push(user.userID);
							}					
							
						});
					
						if($userList.find("li:not(.of-placeholder)").length > 1) {

							$userList.removeClass("of-hidden");
							$submitButton.removeClass("of-hidden");
	
						}
					}
				}
				
			});			
			
			$("#search-group-result").hide();
			$('#search-group').trigger("blur").val("");			
		}
	}
	
});

function isValidEmail(email) {
	
	var regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
	
	return regex.test(email)
	
}
