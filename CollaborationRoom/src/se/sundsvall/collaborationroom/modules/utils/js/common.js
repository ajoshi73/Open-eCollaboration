$(document).ready(function() {
	
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
	
});

function generateUUID() {
	var chars = '0123456789abcdef'.split('');
	var uuid = [], rnd = Math.random;
	var r;
	uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
	uuid[14] = '4';
	for (var i = 0; i < 36; i++) {
		if (!uuid[i]) {
			r = 0 | rnd()*16;
			uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r & 0xf];
		}
	}
	return uuid.join('');
}

function initOFToolBoxes($toolboxes) {
	
	$toolboxes.each(function() {
		
		var $this = $(this);
		
		var tooltip = "";
		
		$this.find("ul li a span").each(function() {
			tooltip += $(this).text() + ", ";
		});

		$this.attr("data-of-tooltip", tooltip.substring(0, tooltip.length-2));
		
	});
	
};