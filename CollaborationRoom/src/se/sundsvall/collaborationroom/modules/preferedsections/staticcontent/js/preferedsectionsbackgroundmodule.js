var preferedSectionsConnector;

$(document).ready(function() {
	
	$("#PreferedSectionsModule .of-modal .of-btn-submit").click(function(e) {
		
		e.preventDefault();
		
		window.location = preferedSectionsConnector + "/add/" + $("#PreferedSection").val();
		
	});
	
});