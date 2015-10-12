var fileArchiveModuleAlias;
var attachFiles = false;
var i18nFileUploadModule = {
	"MARKED_FILES_SINGULAR" : 'marked file',
	"MARKED_FILES_PLURAL" : 'marked files'
};

$(document).ready(function() {
	
	$.fn.ofFileupload = function() {
    	
    };
	
	$("a.submit-btn, button.submit-btn").click(function(e) {
		
		e.preventDefault();
		
		var $form = $(this).closest("form.of-form");

		$(this).focus();
		
		if($form.find(".of-input-error").length == 0) {
			
			$form.submit();
		
		} else if(!$form.hasClass("no-auto-scroll")) {
			
			$("html, body").animate({ scrollTop: ($(".of-input-error").first().offset().top - 75)  }, "fast");
		}
		
	});

	$("[data-of-open-modal='update-category']").click(function(e) {
		
		e.preventDefault();
		
		var $modal = $("div[data-of-modal='update-category']");
		
		resetModalDialog($modal);
		
		var $category = $(this).closest("div.category");
		
		$modal.find("input[name='categoryID']").val($category.data("categoryid"));
		$modal.find("header h2").text($category.data("name"));
		$modal.find("input[name='name']").val($category.data("name"));
		
	});
	
	$("[data-of-open-modal='email-help']").click(function(e) {
		
		e.preventDefault();
		
		var modal = $("div[data-of-modal='email-help']");
		
		var category = $(this).closest("div.category");
		var title = category.find("> header > h3 > span");

		var origText = modal.find(".HelpTextOrig").html();
		
		modal.find(".HelpText").html(origText.replace('%Category', "<strong>" + title.text() + "</strong>"));
	});
	
	$("#fileCategoryFilter").change(function(e) {
		
		var filterOn = $(this).val();
		var hiddenCount = 0;
		
		$("div[data-categoryid]").each(function() {
			
			var category = $(this);
			
			if(filterOn === "" || category.data("categoryid") == filterOn){
				
				category.show();
				
			} else {
				
				category.hide();
				hiddenCount++;
			}
		});
		
		var notice = $("#fileCategoryFilterNotice");
		
		if(hiddenCount > 0){
			
			notice.children("span").text(hiddenCount);
			notice.show();
		} else {
			
			notice.hide();
		}
		
		Cookies.set("fileCategoryFilter", filterOn);
	});
	
	var fileCategoryFilter = Cookies.get("fileCategoryFilter");
	
	if(fileCategoryFilter !== undefined){
		var select = $("#fileCategoryFilter");
		select.val(fileCategoryFilter);
		select.trigger("change");
	}
	
	$("#fileSorter").change(function(e) {
		
		var sortOn = $(this).val();
		
		$(".of-attachment-list").each(function() {
			
			var $this = $(this);
			
			var $files = $this.find("li.file");
			
			if(sortOn == "posted" || sortOn == "updated" || sortOn == "size") {
				
				$files.sort(function(file1, file2) {
				
					var val1 = $(file1).data(sortOn);
					var val2 = $(file2).data(sortOn);
					
					if(val1 == "") {
						return 1;
					}
					
					if(val2 == "") {
						return -1;
					}
					
					return parseInt(val1) < parseInt(val2) ? 1 : -1;
				
				});
				
			} else {
				
				$files.sort(function(file1, file2) {
					return $(file1).data("name").localeCompare($(file2).data("name").toUpperCase());
				});
				
			}
			
			$this.find("li.file").detach();
			$this.prepend($files);
			
		});
		
	});
	
	$("#file-filter").keyup(function (e) {
		
		var keyCode = e.which;
		
		var val = $(this).val();
		
		var $files = $(".of-attachment-list li.file");
		
		if(val == "") {

			$files.show();
			return;
		}
		
		$files.hide();
		$files.parent().find("li[data-name*='" + val.toLowerCase() + "']").show();
		
    });
	
	initFile($(".of-attachment-list li"), false)
	
	resetModalDialog = function($modalDialog) {
		
		$modalDialog.find(".of-input-error").removeClass("of-input-error");
		$modalDialog.find("span.error").remove();
		
		var $file = $modalDialog.find("input[type='file']");
		$file.replaceWith($file.clone().val(""));
		
	};
	
	if(document.location.hash == "#addcategory") {
		
		$("[data-of-toggled='addcategory']").removeClass("of-hidden");
		
	}
	
	initOFToolBoxes($("nav.of-toolbox"));
	
	$("#attachfile-bar form").submit(function(e) {
		
		var $form = $(this);

		$form.find("input[name='fileID']").remove();
		
		$(".of-attachment-list li.file input[name='fileID']:checked").each(function() {
			
			$form.append("<input type='hidden' name='fileID' value='" + $(this).val() + "' />");
			
		});
		
	});
	
	$(".of-attachment-list li.file input[name='fileID']").first().trigger("change");
	
});

function initFile($file, initOF) {
	
	$file.find("[data-of-open-modal='update-file']").click(function(e) {
		
		e.preventDefault();
		
		var $modal = $("div[data-of-modal='update-file']");
		
		resetModalDialog($modal);
		
		var $file = $(this).closest("li.file");
		
		$modal.find("input[name='fileID']").val($file.data("fileid"));
		$modal.find("header h2").text($file.data("name"));
		
		var $select = $modal.find("select[name='categoryID']");
		$select.val($file.closest(".category").data("categoryid"));
		$select.parent().find("header span").text($select.find("option:selected").text());
		
		var $input = $modal.find("input[name='autocomplete-tags']");
		$input.val($file.data("tags"));
		$input.data("of-autocomplete", $input.data("gettagsbase"));
		$input.ofAutoComplete();
		
		$modal.show();
		
	});
	
	$file.find("[data-of-open-modal='replace-file']").click(function(e) {
		
		e.preventDefault();
		
		var $modal = $("div[data-of-modal='replace-file']");
		
		resetModalDialog($modal);
		
		var $file = $(this).closest("li.file");
		
		$modal.find("input[name='fileID']").val($file.data("fileid"));
		
		$modal.show();
		
	});
	
	if(attachFiles) {

		var $checkbox = $file.find("input[name='fileID']");
		
		$checkbox.removeClass("of-hidden");
		
		$checkbox.change(function() {
			
			var count = $(".of-attachment-list li.file input[name='fileID']:checked").length;
			
			if(count == 1) {
				$("#attached-files-count").text(count + " " + i18nFileUploadModule.MARKED_FILES_SINGULAR)
			} else {
				$("#attached-files-count").text(count + " " + i18nFileUploadModule.MARKED_FILES_PLURAL)
			}
			
		});
		
	}
	
	if(initOF) {
		
		$file.find("nav.of-toolbox").ofToolbox();
		initOFToolBoxes($file.find("nav.of-toolbox"));
	}
	
}