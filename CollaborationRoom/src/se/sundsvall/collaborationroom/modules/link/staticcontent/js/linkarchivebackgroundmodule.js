var linkArchiveModuleAlias;

$(document).ready(function() {
	
	$("#showMoreLinksLink").click(function(e) {
		
		e.preventDefault();
		
		var $link = $(this);
		
		$link.ofLoading();
		
		var nextIndex = $("ul.of-link-list > li").length;
		
		$.ajax({
			cache: false,
			url: linkArchiveModuleAlias + "/getlinks/" + nextIndex,
			dataType: "html",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				response = $.trim(response)
				
				if(response != "") { 
					
					var $response = $(response);
					
					$("ul.of-link-list").append($response);
					
					$("html, body").animate({ scrollTop: $response.siblings(":nth-child(" + nextIndex + ")").offset().top }, "slow", function() {
						
						$link.ofLoading(false);
						
					});
				
				} else {
					
					setTimeout(function() { $link.ofLoading(false); $link.parent().remove(); }, 500)
					
				}
				
			}
		});
		
	});
	
});