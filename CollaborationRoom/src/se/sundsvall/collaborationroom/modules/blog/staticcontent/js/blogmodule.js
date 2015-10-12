var blogModuleAlias;
var currentIndex = 0;
var i18nBlogModule = {
		"READ_MORE": "Read more",
		"HIDE_TEXT": "Hide text",
	};

$(document).ready(function() {
	
	$(document).on('click', '.show-on-focus-toggle', function(e) {

        $('.show-on-focus').show();
        
        $('.show-on-focus-toggle').find('input').focus();

    });
	
	 $(document).on('focus', 'textarea[name="comment"]', function() {
         
         $(this).parent().parent().find('.of-post-comment').show();
     });
	
	$("#showMoreLink").click(function(e) {
		
		e.preventDefault();
		
		var $link = $(this);
		
		$link.ofLoading();
		
		var nextIndex = $("ul.of-post-list > li").length;
		
		$.ajax({
			cache: false,
			url: blogModuleAlias + "/getposts/" + nextIndex,
			dataType: "html",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				response = $.trim(response)
				
				if(response != "") {
					
					var $response = $(response);
					
					addExpander($response.find(".article-content"));
					
					$("ul.of-post-list").append($response);
					
					$response.find(".of-toolbox").each(function() { $(this).attr("data-id", generateUUID()).ofToolbox(); initOFToolBoxes($(this)); });
					
					var offset = $response.siblings(":nth-child(" + (nextIndex + 1) + ")").offset();
					
					if(offset != null) {
						
						$("html, body").animate({ scrollTop: offset.top }, "slow", function() {
							
							$link.ofLoading(false);
							
						});
						
					} else {
						$link.ofLoading(false);
					}
				
				} else {
					
					setTimeout(function() { $link.ofLoading(false); $link.parent().remove(); }, 500);
					
				}
				
			}
		});
		
	});
	
	$(".comments-wrap form.of-form input[type='submit']").click(function(e) {
		
		e.preventDefault();
		
		if($("#comment").val() != "") {
			
			$(this).closest("form.of-form").submit();
			
		}
		
	});
	
	$("ul.of-comment-list li.comment").each(function(e) {
	
		var $this = $(this);
		
		var $form = $this.find("form.update-comment-form");
		$form.find("a.cancel-btn").click(function(e) {
			$form.addClass("of-hidden").prev("span.comment-message").show();
		});
		
		$this.find("nav.of-toolbox ul li a.update-comment-btn").click(function(e) {
	
			e.preventDefault();
			
			$form.removeClass("of-hidden").prev("span.comment-message").hide();
			
			var $textarea = $form.find("textarea");
			
			var val = $textarea.val();
			
			$textarea.val("").val(val);
			$textarea.focus().click();
		});
		
	});
	
	var $updatePostForm = $("#update-post-form");
	
	$updatePostForm.find("a.cancel-btn").click(function(e) {
		
		$("#update-post-form").addClass("of-hidden");
		window.location.hash = "";
		
	});
	
	$("#attach-file-link").click(function(e) {
		
		e.preventDefault();
		
		var $form = $(".post-form");
		
		$form.attr("method", "GET");
		$form.attr("action", $(this).data("attachfileuri"));
		
		$form.submit();
		
	});
	
	if(document.location.hash == "#update") {
		$("#update-post-form").removeClass("of-hidden");
	} else if(document.location.hash == "#add") {
		
		$("[data-of-toggled='new-post']").removeClass("of-hidden");
	
	} else if(document.location.hash == "#attachedfiles") { 
		
		$("[data-of-toggled='new-post']").removeClass("of-hidden");
		$("#update-post-form").removeClass("of-hidden");
		$('html,body').animate({scrollTop: $("a[name='attachedfiles']").offset().top - 130}, "fast");
		
	} else if(document.location.hash == "#comment") {
		$("#comment").focus();
	}
	
	$(window).bind('hashchange', function () {
		
		if(document.location.hash == "#update") {
			
			$("#update-post-form").removeClass("of-hidden");
			
		}
		
	});

	initOFToolBoxes($("nav.of-toolbox"));
	
	$(".of-attachment-list li a.delete-btn").click(function(e) {
		
		e.preventDefault();
		
		$(this).closest("li.file").slideUp().remove();
		
	});
	
	addExpander($(".article-content"));
	
});

function addExpander(node){
	node.expander({
		slicePoint : 150,
		expandText : i18nBlogModule.READ_MORE,
		userCollapseText : i18nBlogModule.HIDE_TEXT,
		expandEffect: "show",
		collapseEffect: "hide",
		detailClass: "of-show-more",
		expandSpeed: 0,
		collapseSpeed: 0,
		afterExpand: function() {
			$(this).find(".of-show-more").css("display", "inline");
		}
	});
	
	node.show();
}