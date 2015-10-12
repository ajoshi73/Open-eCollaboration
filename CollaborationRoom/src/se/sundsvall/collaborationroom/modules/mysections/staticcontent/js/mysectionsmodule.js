var mySectionsModuleAlias;

$(document).ready(function() {
	
	var $roomFilter = $("#room-filter-select");
	
	$roomFilter.change(function(e) {
		
		var $this = $(this);
		
		var selectedFilter = $this.val();

		var $gridItems = $("#MySectionsModule ul.of-grid-list > li");
		
		$gridItems.hide();
		$gridItems.filter("[data-mode='" + selectedFilter + "']").show();
		
		var $listItems;
		
		if(selectedFilter == "MY") {
			$("#MySectionsTable").show();
			$("#OtherSectionsTable").hide();
			$listItems = $("#MySectionsTable tbody tr");
		} else {
			$("#OtherSectionsTable").show();
			$("#MySectionsTable").hide();
			$listItems = $("#OtherSectionsTable tbody tr");
		}
		
		var itemsLength = $listItems.length;
		
		if(itemsLength == 0) {
			$gridItems.parent().append($("<li>" + $("#no-sections-template").text() + "</li>"));
			$listItems.parent().append($("<tr><td colspan='3'>" + $("#no-sections-template").text() + "</td></tr>"));
			$("#show-more-sections").hide();
		} else {
			$("#show-more-sections").show();
		}
		
	});
	
	$roomFilter.trigger("change");
	
	$("#show-more-sections").click(function(e) {
		
		e.preventDefault();
		
		var $link = $(this);
		
		$link.ofLoading();
		
		var selectedFilter = $roomFilter.val();
		var viewMode = $("#view-toggler .of-active").data("of-toggler-multiple");
		
		var nextIndex = $("#MySectionsModule ul.of-grid-list > li[data-mode='" + selectedFilter + "']").length;
		
		$.ajax({
			cache: false,
			url: mySectionsModuleAlias + "/getsections/" + nextIndex + "/" + selectedFilter,
			dataType: "html",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				response = $.trim(response);
				
				if(response != "") { 
					
					var $response = $("<div>" + response + "</div>");
					
					var $gridResult = $response.find(".grid-items > li");
					$("#MySectionsModule ul.of-grid-list").append($gridResult.show());
					
					var $listResult = $response.find("table tbody tr");
					var $myRows = $listResult.filter("[data-mode='MY']");
					var $otherRows = $listResult.filter("[data-mode!='MY']");
					
					$("#MySectionsTable tbody").append($myRows).trigger("addRows", [$myRows, false]);
					$("#OtherSectionsTable tbody").append($otherRows).trigger("addRows", [$otherRows, false]);
					
					var offset = null;
					
					if(viewMode == "grid") {
						offset = $gridResult.siblings(":nth-child(" + nextIndex + ")").offset();
					} else {
						offset = $listResult.siblings(":nth-child(" + nextIndex + ")").offset();
					}
					
					$("html, body").animate({ scrollTop: offset.top }, "slow", function() {
						$link.ofLoading(false);
					});
						
				
				} else {
					
					setTimeout(function() { $link.ofLoading(false); $link.hide(); }, 500);
					
				}
				
			}
		});
		
	});
	
});