$(document).ready(function() {
	
	$("a.submit-btn, button.submit-btn").click(function(e) {
		
		e.preventDefault();
		
		var $form = $(this).closest("form.of-form");

		$(this).focus();
		
		if($form.find(".of-input-error").length == 0) {

			$form.submit();
		
		}
		
	});
	
});