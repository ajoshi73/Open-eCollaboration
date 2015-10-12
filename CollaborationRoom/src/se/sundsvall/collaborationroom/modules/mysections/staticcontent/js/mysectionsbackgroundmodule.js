var mySectionsModuleAlias;

$(document).ready(function() {
	
	$("select[name='samarbetsrum-select']").change(function() {
		
		var href = $(this).find(":selected").data("href");
		
		if(href != "#") {
			window.location = href;
		}
		
	});
	
});