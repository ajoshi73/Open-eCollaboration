var calendarModuleAlias;

$(document).ready(function() {
	
	$("#startTime, #endTime").timePicker({
		startTime: "00:00",
		endTime: "23:59",
		step: 15
	});
	
	$("a.submit-btn, button.submit-btn").click(function(e) {
		
		var $form = $(this).closest("form.of-form");

		$(this).focus();
		
		if($form.find("[data-of-required].of-input-error").length == 0) {

			$form.submit();
		
		} else {
			
			$("html, body").animate({ scrollTop: ($(".of-input-error").first().offset().top - 75)  }, "fast");
			
		}
		
	});
	
	$("#wholeDay").on('change', function() {
		
		var $this = $(this);
		
		if($this.val() == 1) {
			
			$("#startTime, #endTime").parent().parent().hide();
			
		} else {
			
			$("#startTime, #endTime").parent().parent().show();
			
		}
		
	});
	
	$("#startDate").on("blur", function() {
		
		var $this = $(this);
	
		if($this.val() != "") {
		
			var startDate = Date.parse($this.val());
		
			var endDate = $("#endDate").val();

			if(endDate == "" || startDate > Date.parse(endDate)) {
				
				$("#endDate").val($this.val());
				
			}
			
		}
		
	});
	
	$("#wholeDay").trigger("change");
	
	var $firstDay = $("article.day").first();
	
	if($firstDay.length > 0) {
		$(".agenda-controls").append($firstDay.prev("header").html());
		$firstDay.removeClass("of-inner-padded-t-half");
		$firstDay.prev("header").remove();
	}
	
	$("#showMoreLink").click(function(e) {
		
		e.preventDefault();
		
		var $link = $(this);
		
		$link.ofLoading();
		
		var $lastDay = $("article.day").last();
		
		var lastDate = $lastDay.data("date");
		
		$.ajax({
			cache: false,
			url: calendarModuleAlias + "/loadmoredays?lastdate=" + lastDate,
			dataType: "html",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) {  },
			success: function(response) {
				
				response = $.trim(response)
				
				if(response != "") { 
					
					var $response = $(response);
					
					$response.insertAfter($lastDay);
					
					$("html, body").animate({ scrollTop: $response.first().offset().top }, "slow", function() {
						
						$link.ofLoading(false);
						
					});
				
				} else {
					
					setTimeout(function() { $link.ofLoading(false); $link.remove(); }, 500)
					
				}
				
			}
		});
		
	});
	
	$(document).on("click", "a.clndr-previous-button, a.clndr-next-button, .of-calendar .calendar-row a", function(e) {
		e.preventDefault();
    });
	
	$("#sectionToggler.month").change(function() {
		
		var value = $(this).val();
		
		var $calendar = ofCalendars["monthCalendar"];
		if($calendar != undefined) {
			if(value != "") {
				ofCalendarAjaxUrl = ofCalendarAjaxBaseUrl + "?sectionID=" + value;
			} else {
				ofCalendarAjaxUrl = ofCalendarAjaxBaseUrl;
			}
			$calendar.setMonth($calendar.getMonth(),{ withCallbacks: true });
		}
		
	});
	
	$("#sectionToggler.agenda").change(function() {
		
		var value = $(this).val();
		
		if(value != "") {
			window.location = calendarModuleAlias + "?view=agenda&sectionID=" + value;
		} else {
			window.location = calendarModuleAlias + "?view=agenda";
		}
		
	});
	
});