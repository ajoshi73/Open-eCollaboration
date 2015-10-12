+ function($) {

    'use strict';
    
    $.fn.ofFileupload = function() {
    	
    };
    
}(jQuery);

$(document).ready(function() {
	
	// TODO temporary disable of fileupload plugin
	$.fn.ofFileupload = function() {
    	
    };
	
	if($(".validationerrors").length > 0) {
		
		$(".validationerrors").each(function() {
			
			var $this = $(this);
			
			var $form = $this.closest("form");
			
			$this.find("span.validationerror").each(function(i) {
				
				var $error = $(this);
				
				if($error.data("parameter")) {
					
					var $element = $form.find("[name='" + $error.data("parameter") + "']");
					
					$element.parent().addClass("of-input-error").addClass("of-icon");
					
					$($error.html()).insertAfter($element);
					
				}
				
			});
			
			var $wrapper = $form.parent();
			
			if($wrapper.data("of-modal")) {
				
				$this.trigger("click");
				
			} else {
				
				$form.removeClass("of-hidden");
				$wrapper.removeClass("of-hidden");
				
			}
			
		});
		
	}
	
	$("form.of-form button[type='submit']").click(function(e) {
		
		e.preventDefault();
		
		var $form = $(this).closest("form.of-form");

		$(this).focus();
		
		if($form.find("label.of-input-error").length == 0) {

			$form.submit();
		
		}
		
	});
	
	$(".of-uploaded a").click(function(e) {
		
		e.preventDefault();
		
		$(this).parent().parent().removeClass('of-file-uploaded');
		$(this).parent().find("input[type='hidden']").val("true");
		
	});
	
});