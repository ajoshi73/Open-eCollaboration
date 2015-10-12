var tasksModuleAlias;
var i18nTaskBackgroundModule = {
	"FINISHED_BY": "Finished by",
	"FINISHED_TITLE": 'Mark task as finished',
	"NOT_FINISHED_TITLE": 'Mark task as not finished'
};

$(document).ready(function() {
	
	$("ul.of-todo-list input").change(function(e) {
		
		toggleTask($(this));
		
	});
	
	$("#showMoreTasksLink").click(function(e) {
		
		e.preventDefault();
		
		var $link = $(this);
		
		$link.ofLoading();
		
		var nextIndex = $("ul.of-todo-list > li").length;
		
		$.ajax({
			cache: false,
			url: tasksModuleAlias + "/gettasks/" + nextIndex,
			dataType: "html",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				response = $.trim(response)
				
				if(response != "") { 
					
					var $response = $(response);
					
					$("ul.of-todo-list").append($response);
					
					$response.find("input").change(function(e) {
						toggleTask($(this));
					});
					
					$("html, body").animate({ scrollTop: $response.siblings(":nth-child(" + nextIndex + ")").offset().top }, "slow", function() {
						
						$link.ofLoading(false);
						
					});
				
				} else {
					
					setTimeout(function() { $link.ofLoading(false); $link.parent().remove(); }, 500)
					
				}
				
			}
		});
		
	});
	
	var toggleTask = function($this) {
		
		$.ajax({
			cache: false,
			url: $this.closest("li").data("toggletaskalias") + "/" + $this.val(),
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) { },
			success: function(response) {

				var result = eval(response);
				
				$li = $this.closest("li");
				
				if(result.finished) {
					
					$li.addClass("completed");
					$li.find(".of-checkbox-label span").append("<span class='completed-by'><i>(" + i18nTaskBackgroundModule.FINISHED_BY + " " + result.finishedBy + " " + result.finished + "</i></span>");
					$li.find(".of-checkbox-label label em").attr("data-of-tooltip", i18nTaskModule.NOT_FINISHED_TITLE);
					
				} else {
					
					$li.removeClass("completed");
					$li.find(".completed-by").remove();
					$li.find(".of-checkbox-label label em").attr("data-of-tooltip", i18nTaskModule.FINISHED_TITLE);
					
				}
				
			}
		});
		
	};
	
});