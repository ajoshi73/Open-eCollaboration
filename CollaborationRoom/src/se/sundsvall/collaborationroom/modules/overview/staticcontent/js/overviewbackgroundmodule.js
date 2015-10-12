var toggleFavouriteURI;
var membersModuleURI;
var i18nOverviewBgModule = {
	"READ_MORE": "Read more",
	"HIDE_TEXT": "Hide text",
	"ADDED_FAVOURITE": "added as favourite",
	"DELETED_FAVOURITE": "deleted as favourite",
	"ADD_AS_FAVOURITE": 'Add as favourite',
	"DELETE_AS_FAVOURITE": 'Delete as favourite',
	"FOLLOW_SUCCESS": 'You are now following',
	"UNFOLLOW_SUCCESS": 'You are now removed as follower from',
	"FOLLOW": 'Follow',
	"UNFOLLOW": 'Stop follow'
};

$(document).ready(function() {
	
	var $wrapper = $("#OverviewBackgroundModule");
	
	if($("#ShortCutsBackgroundModule").length > 0) {
		$wrapper.css("border-bottom", 0);
	}
	
	$wrapper.find(".description").expander({
		slicePoint : 150,
		expandText : i18nOverviewBgModule.READ_MORE,
		userCollapseText : i18nOverviewBgModule.HIDE_TEXT,
		expandEffect: "show",
		collapseEffect: "hide",
		detailClass: "of-show-more",
		expandSpeed: 0,
		collapseSpeed: 0,
		afterExpand: function() {
			$(this).find(".of-show-more").css("display", "inline");
		}
	});
	
	$wrapper.find(".description").show();
	
	$wrapper.find("a.of-favourite").click(function(e) {
		
		e.preventDefault();
        
		var $this = $(this);
		
		$.ajax({
			type: "GET",
			cache: false,
			url: toggleFavouriteURI + "/" + $this.data("sectionid"),
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				if(response.AddSuccess) {
					
					$this.addClass('favourited');
					$this.attr("data-of-tooltip", i18nOverviewBgModule.DELETE_AS_FAVOURITE);
					
					new OF_Notification($this.parent().text() + " " + i18nOverviewBgModule.ADDED_FAVOURITE);
					
				} else if(response.DeleteSuccess) {
					
					$this.removeClass('favourited');
					$this.attr("data-of-tooltip", i18nOverviewBgModule.ADD_AS_FAVOURITE);
					
					new OF_Notification($this.parent().text() + " " + i18nOverviewBgModule.DELETED_FAVOURITE);
					
				}
				
			}
		});
		
	});
	
	$wrapper.find("a.of-btn-follow").click(function(e) {
		
		 e.preventDefault();
		 
		 var $this = $(this);
		 
		 $this.addClass("of-loading");
		 
		 $.ajax({
			type: "GET",
			cache: false,
			url: membersModuleURI + "/togglefollow",
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				var name = $this.closest("header").find(".room-heading").text();
				
				if(response.AddSuccess) {
					
					$this.find("span").text(i18nOverviewBgModule.UNFOLLOW);
					
					$this.addClass('following');
					
					new OF_Notification(i18nOverviewBgModule.FOLLOW_SUCCESS + " " + name);
					
					setTimeout(function(){ $this.removeClass('following'); }, 2000);
					
				} else if(response.DeleteSuccess) {
					
					$this.find("span").text(i18nOverviewBgModule.FOLLOW);
					
					$this.removeClass('following');
					
					new OF_Notification(i18nOverviewBgModule.UNFOLLOW_SUCCESS + " " + name);
					
				}
				
				$this.removeClass("of-loading");
				
			}
		});
		
	});
	
	$wrapper.find("a.of-show-more").click(function(e) {
		
		e.preventDefault();
		
		$(this).next().removeClass("of-hide-to-sm").show();
		$(this).hide();
		
	});
	
});