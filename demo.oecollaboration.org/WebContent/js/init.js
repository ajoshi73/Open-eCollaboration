$(document).ready(function() {

	$("nav.mobile-menu ul[data-of-menu].li.menuitem.active a")
	
	var $mobileMenu = $("nav.mobile-menu ul[data-of-menu]");
	
	var $selectedItem = $mobileMenu.find("li.menuitem.active a");
	
	var $clone = $selectedItem.clone();
	$clone.addClass("of-btn of-btn-toggler of-btn-svartvik");
	$clone.attr("data-of-toggle-menu", "main");
	$clone.find("i").replaceWith('<i><svg viewBox="0 0 512 512" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"><use xlink:href="#arrow-down"/></svg></i>');
	
	$mobileMenu.parent().find("> h3").before($clone);
	
});