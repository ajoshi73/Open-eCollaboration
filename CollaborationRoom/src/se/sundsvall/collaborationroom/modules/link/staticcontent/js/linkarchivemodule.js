var linkArchiveModuleAlias;

$(document).ready(function() {
	
	
	$("[data-of-open-modal='update-link']").click(function(e) {
		
		var $modal = $("div[data-of-modal='update-link']");
		
		resetModalDialog($modal);
		
		var $link = $(this).closest("li");
		
		$modal.find("input[name='linkID']").val($link.data("linkid"));
		$modal.find("header h2").text($link.data("name"));
		$modal.find("input[name='name']").val($link.data("name"));
		$modal.find("input[name='url']").val($link.find(".of-checkbox-label a").attr("href"));
		
	});
	
	resetModalDialog = function($modalDialog) {
		
		$modalDialog.find(".of-input-error").removeClass("of-input-error");
		$modalDialog.find("span.error").remove();
	
	};
	
	$("a.submit-btn, button.submit-btn").click(function(e) {
		
		var $form = $(this).closest("form.of-form");

		$(this).focus();
		
		if($form.find(".of-input-error").length == 0) {

			$form.submit();
		
		} else if(!$form.hasClass("no-auto-scroll")) {
			
			$("html, body").animate({ scrollTop: ($(".of-input-error").first().offset().top - 75)  }, "fast");
		}
		
	});
	
	if(document.location.hash == "#add") {
		
		$("[data-of-toggled='addlink']").removeClass("of-hidden");
		
	}
	
});