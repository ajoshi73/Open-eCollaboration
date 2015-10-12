var allowedFileTypes = null;
var maxFileSize = null;
var i18nFileUpload = {
	"INVALID_FILE": 'This file has an incorrect file type',
	"ALLOWED_FILE_TYPES": 'Allowed file types are',
	"FILE_SIZE_TO_BIG": 'This file is to big',
	"UNKOWN_FILEUPLOAD_ERROR": 'An unkown error occured when uploading image'
};
var supportsFileReader = (typeof FileReader !== "undefined");
var supportsPlaceHolder = ("placeholder" in document.createElement("input"));

$(document).ready(function() {
	
	if(supportsFileReader) {
	
	    $("#FileArchiveModule").on("dragover", ".category", function(e) {
	
	    	e.preventDefault();
	    	
	    	var $filesWrapper = $(this).find(".of-attachment-list");
	    	
	        if ($filesWrapper.hasClass("of-fileover")) {
	            return false;
	        }
	
	        $filesWrapper.addClass("of-fileover");
	
	    }).on("dragleave", ".category", function(e) {
	        
	    	e.preventDefault();
	    	
	    	var $filesWrapper = $(this).find(".of-attachment-list");
	    	
	        $filesWrapper.removeClass("of-fileover");
	
	    }).on("dragenter", ".category", function(e) {
	
	    	e.preventDefault();
	    	
	    });
    
	}
    
	if(!supportsPlaceHolder) {
		
		$("input[placeholder]").removeAttr("placeholder");
	}
	
    $("#FileArchiveModule .category .of-attachment-list").each(function() {
    	
    	var fileData = [];
    	var contexts = {}    
    	var jqXHR = null;
    	var currentUploadIndex = 0;
    	var initEvents = true;
    	
    	var $this = $(this);
    	
    	var $fileInput = $this.find(".fileinput");
    	
    	var $uploadForm = $this.find("form");
    	
        $fileInput.fileupload({
            dropZone: $this.closest("div.category"),
            autoUpload: false,
            
            dataType: "html",
            progress: function(e, data) {
            	
            	var progress = parseInt(data.loaded / data.total * 100, 10);
            	
            	var files = data.files;
            	
            	$.each(files, function(i, file) {
            		
            		contexts[file.name].find("progress.of-progress").attr("value", progress);
            		
            	});
            	
            },
            add: function(e, data) {
            	
            	$this.removeClass("of-fileover");
            	
                var file = data.files[0];

                if(initEvents) {
                	
                	var $btns = $(".of-attachment-template").find(".btn-clone").clone().removeClass("btn-clone");
                	
                	$btns.find(".upload-btn").click(function(e) {
                	
                		e.preventDefault();
                	
                		$(this).attr("disabled", "disabled");
                		
                		sendFile(0);
                		
                	});
                
                	$btns.find(".cancel-btn").click(function(e) {
	                	
	                	e.preventDefault();
	                	
	                	resetFileUpload();
	                	
	                });
                	
                	$this.find(".upload-files").before($btns);
                	
                	initEvents = false;
                	
                }
                
                var fileExtension = file.name.substr(file.name.lastIndexOf(".") + 1);

                var $fileWrapper = $(".of-attachment-template").find(".file-clone").clone().removeClass("file-clone");
                
                if(fileData.length == 0) {
                	$fileWrapper.addClass("first-file");
                }
                
                $fileWrapper.addClass("queued");
                $fileWrapper.find("div > span").text(file.name);
                $fileWrapper.find(".progress").append("<progress class='of-progress' value='0' max='100' />");
    			var $icon = $fileWrapper.find("img");
    			$icon.attr("src", $icon.data("fileiconbase") + "/" + file.name);
    			
    			if (typeof FileReader !== "undefined") {
    				$fileWrapper.find(".filesize").text(bytesToSize(file.size));
    			}
    			
    			var $input = $fileWrapper.find("input[name='autocomplete-tags']");
    			
    			$input.data("of-autocomplete", $input.data("gettagsbase"));
    			$input.ofAutoComplete();
    			
                if(!isValidFileExtension(fileExtension)) {
                	
                	$fileWrapper.find(".file-form-elements").hide();
                	$fileWrapper.find(".error-label").html("<span class='description error'>" + i18nFileUpload.INVALID_FILE + "<br/>" + i18nFileUpload.ALLOWED_FILE_TYPES + ": " + allowedFileTypes.join(", ") + "</span>").show();
                	
                } else if(!isValidSize(file.size))  {
                	
                	$fileWrapper.find(".file-form-elements").hide();
                	$fileWrapper.find(".error-label").text("<span class='description error'>" + i18nFileUpload.FILE_SIZE_TO_BIG + "</span>").show();
                	
                } else {
                	
                	$fileWrapper.attr("id", "queueID_" + fileData.length);
                	fileData.push(data);
        			contexts[file.name] = $fileWrapper;
                	                	
                }
                
    			$fileWrapper.show();
    			$this.find(".upload-btns").show().before($fileWrapper);
    			
    			var currentScrollTop = $(document).scrollTop();
    			var queueOffset = $this.find(".queued").first().offset().top;

    			if(currentScrollTop < queueOffset) {
    			
    				$("html, body").animate({ scrollTop: (queueOffset - 100)  }, "fast");
    			
    			}
            },
            done: function(e, data) {
            	
            	var currentFile = fileData[currentUploadIndex];
            	
            	var response = data.result;
            	
            	if (response.indexOf("validationerror") > -1) {
            	     
                	fileError(currentFile.files[0], response);
                	
        	    } else {
        	    	
        	    	fileFinished(currentFile.files[0]);
            		
            		var $file = $(response);
                	
                	initFile($file, true);
            		
                	if($this.find("li[data-fileid]").length > 0) {
                		$this.find("li[data-fileid]").last().after($file);
                	} else {
                		$this.find("li.empty").replaceWith($file);
                	}
        	    	
        	    }
            	
            	currentUploadIndex++;
            	
            	sendFile(currentUploadIndex);
            	
            }
            
        }).prop("disabled", !$.support.fileInput).parent().addClass($.support.fileInput ? undefined : "disabled"); // Disable the file upload if it isn't supported;
    	

		$uploadForm.ajaxForm({
            beforeSubmit: function(arr, form, options) {
            	
            },
            error: function(jqXHR, textStatus, errorThrown) {
            	
            	alert(i18nFileUpload.UNKOWN_FILEUPLOAD_ERROR);
            	
            }
        });
		
		$uploadForm.on("submit", function(e){

            sendFile(0);
            
        });
		
		if(!supportsFileReader) {
			$uploadForm.find(".of-upload span.title").text("");
		}
		
		var sendFile = function(index) {
	    	
	    	if(index < fileData.length) {
	    	
	    		var currentFileData = fileData[index];
	    	
	    		$uploadForm.find("input[name='tags']").val($("#queueID_" + index + " input[name='tags']").val());
	    		
	    		currentFileData.submit();
	    		
	    	} else {
	    		
	    		jqXHR = null;
	    		
	    		resetFileUpload();
	    		
	    	}
	    	
	    };
	    
	    var fileFinished = function(file) {

	    	contexts[file.name].slideUp().remove();
	    	
	    };
	    
	    var fileError = function(file, errorMessage) {

	    	var $file = contexts[file.name];
	    	$file.find(".file-form-elements").hide();
	    	$file.find(".error-label").html(errorMessage).show();
	    	$file.attr("class", "file");
	    	$file.removeAttr("id");
	    	
        	if($this.find("li[data-fileid]").length > 0) {
        		$this.find("li[data-fileid]").last().after($file);
        	} else {
        		$this.find("li.empty").replaceWith($file);
        	}
        	
	    };
	    
	    var resetFileUpload = function() {
	    	
	    	if(jqXHR != null) { 
        		jqXHR.abort();
        	}
        	
        	$this.find(".queued").remove();
        	$this.find(".upload-btns").remove();
        	
        	fileData = [];
        	contexts = {};
        	
        	currentUploadIndex = 0;
        	
        	initEvents = true;
	    	
	    };
    		
    });

    var bytesToSize = function(bytes) {
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes == 0) return 'n/a';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    };
    
    var isValidFileExtension = function(fileExtention) {
    	
    	if(allowedFileTypes == null || $.inArray(fileExtention.toLowerCase(), allowedFileTypes) != -1) {
    		return true;
    	}
    	
    	return false;
    };
    
    var isValidSize = function(size) {
    	
    	if (supportsFileReader) {
    	
	    	if(maxFileSize == null || maxFileSize >= size) {
	    		
	    		return true;
	    	}
	    	
	    	return false;
	    	
    	}
    	
    	return true;
    };
    
});