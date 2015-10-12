var taskModuleAlias;
var i18nTaskModule = {
	"FINISHED_BY": "Finished by",
	"NEW_TASK": 'New task',
	"FINISH_TASK_ERROR": 'You have not right to finish mark this task because it�s assigned to',
	"FINISHED_TITLE": 'Mark task as finished',
	"NOT_FINISHED_TITLE": 'Mark task as not finished',
	"CREATED_BY": "Created by",
	"EDITED_BY" : "Edited by",
	"FINISHED" : "Finished",
	"ACTIVE" : "Active"
};
var hasFinishedTasks = false;
var previousTaskListFilter;
var previousMembersFilter;
var previousStateFilter;
var filterHasHiddenThings = false;
var tableSelected = false;

$(document).ready(function() {
	
	$("ul.of-todo-list .of-checkbox, table.of-todo-list .of-checkbox").click(function(e) {
		
		e.preventDefault();
		e.stopPropagation();
		
		var $this = $(this);
		
		if(!$this.prev().is(":disabled")) {
		
			var $input = $this.parent().find("input");
			
			$input.prop('checked', !$input.prop('checked'));
			
			$input.trigger("change");
		
		} else {
			
			var responsible = $this.closest("tr,li").find(".responsibleuser").text();
			
			if(responsible != "") {
			
				alert(i18nTaskModule.FINISH_TASK_ERROR + " " + responsible + "!");
			
			}
			
		}
		
	});
	
	$("ul.of-todo-list input, table.of-todo-list input").change(function(e) {
		
		var $this = $(this);
		
		$.ajax({
			cache: false,
			url: $this.closest("[data-toggletaskalias]").data("toggletaskalias") + "/" + $this.val(),
			dataType: "json",
			contentType: "application/x-www-form-urlencoded;charset=UTF-8",
			error: function (xhr, ajaxOptions, thrownError) { },
			success: function(response) {

				var result = eval(response);
				
				var taskid = $this.closest("[data-taskid]").data("taskid");
				
				var tableTask = $("tr[data-taskid='" + taskid + "']");
				var listTask = $("li[data-taskid='" + taskid + "']");
				var both = tableTask.add(listTask);
				
				if(result.finished) {
					
					both.removeClass("ACTIVE");
					both.addClass("completed");
					both.addClass("FINISHED");
					both.find(".of-checkbox-label label em").attr("data-of-tooltip", i18nTaskModule.NOT_FINISHED_TITLE);
					
					tableTask.find("[data-taskstatus]").text(i18nTaskModule.FINISHED);
					
					listTask.find(".of-checkbox-label span").append("<span class='completed-by'><i>(" + i18nTaskModule.FINISHED_BY + " " +
																	result.finishedBy + " " + result.finished + "</i></span>");
					
				} else {
					
					both.removeClass("completed");
					both.removeClass("FINISHED");
					both.addClass("ACTIVE");
					both.find(".of-checkbox-label label em").attr("data-of-tooltip", i18nTaskModule.FINISHED_TITLE);
					
					tableTask.find("[data-taskstatus]").text(i18nTaskModule.ACTIVE);
					
					listTask.find(".completed-by").remove();
				}

				if($this.closest("[data-taskid]").get(0) === tableTask.get(0)){
					listTask.find(".of-checkbox-label input").prop('checked', $this.prop('checked'));
				} else {
					tableTask.find(".of-checkbox-label input").prop('checked', $this.prop('checked'));
				}
			}
		});
		
	});
	
	$("[data-of-open-modal='add-task']").click(function(e) {
		
		var $modal = $("div[data-of-modal='add-task']");
		
		resetModalDialog($modal);
		
		var $select = $modal.find("select[name='taskListID']");
		$select.val($(this).closest("[data-tasklistid]").data("tasklistid"));
		$select.trigger("change");
		
		$modal.find("input[name='title']").parent().show();
	
	});
	
	$("[data-of-open-modal='update-task']").click(function(e) {
		
		var $modal = $("div[data-of-modal='update-task']");
		
		resetModalDialog($modal);
		
		var $task = $(this).closest("[data-taskid]");
		
		$modal.find("input[name='taskID']").val($task.data("taskid"));
		$modal.find("header h2").text($task.data("title"));
		
		$modal.find("input[name='title']").val($task.data("title"));
		
		var $textarea = $modal.find("textarea[name='description']");
		
		$textarea.html($task.data("description"));
		$textarea.trigger("change");
		
		var $taskListSelect = $modal.find("select[name='taskListID']");
		$taskListSelect.val($task.closest("[data-tasklistid]").data("tasklistid"));
		$taskListSelect.trigger("change");
		
		var $userSelect = $modal.find("select[name='responsibleUser']");
		$userSelect.val($task.data("responsibleuser"));
		$userSelect.trigger("change");
		
		$modal.find("input[name='deadline']").val($task.data("deadline"));
		
		if($(this).data("modal-mode") == "assign") {
			$modal.find("input[name='title']").parent().hide();
		} else {
			$modal.find("input[name='title']").parent().show();
		}
	
	});
	
	//For MyTasks
	$("[data-of-open-modal^='update-task-section-']").click(function(e) {
		
		var $task = $(this).closest("li");
		
		var $modal = $("div[data-of-modal='update-task-section-" + $task.closest("[data-sectionid]").data("sectionid") + "']");
		
		resetModalDialog($modal);
		
		$modal.find("input[name='taskID']").val($task.data("taskid"));
		$modal.find("header h2").text($task.data("title"));
		
		$modal.find("input[name='title']").val($task.data("title"));
		
		var $textarea = $modal.find("textarea[name='description']");
		
		$textarea.html($task.data("description"));
		$textarea.trigger("change");
		
		$modal.find(".listnametext").text($task.parent().parent().parent().data("name"));
		$modal.find("[name='taskListID']").val($task.closest("[data-tasklistid]").data("tasklistid"));
		
		var $userSelect = $modal.find("select[name='responsibleUser']");
		$userSelect.val($task.data("responsibleuser"));
		$userSelect.trigger("change");
		
		$modal.find("input[name='deadline']").val($task.data("deadline"));
		
		if($(this).data("modal-mode") == "assign") {
			$modal.find("input[name='title']").parent().hide();
		} else {
			$modal.find("input[name='title']").parent().show();
		}
	
	});
	
	$("[data-of-open-modal='update-tasklist']").click(function(e) {
		
		var $modal = $("div[data-of-modal='update-tasklist']");
		
		resetModalDialog($modal);
		
		var $taskList = $(this).closest("div");
		
		$modal.find("input[name='taskListID']").val($taskList.data("tasklistid"));
		$modal.find("header h2").text($taskList.data("name"));
		$modal.find("input[name='name']").val($taskList.data("name"));
		
	});
	
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
	
	$("ul.of-todo-list.ui-sortable").not(".of-no-sort, .of-widget").sortable({
  		cancel: 'aside',
  		update: function (event, ui) {
	        
  			var $this = $(this);
  			
  			var parameters = {};
  			
  			$this.find("li").each(function(e) {
  				
  				var taskID = $(this).data("taskid");
  				
  				if(taskID != undefined) {
  					parameters["task_" + $(this).data("taskid")] = $(this).index();
  				}
  				
  			});
  			
  			$.ajax({
  				type: "POST",
  				cache: false,
  				url: taskModuleAlias + "/sorttasklist/" + $this.parent().parent().data("tasklistid"),
  				data: parameters,
  				dataType: "json",
  				contentType: "application/x-www-form-urlencoded;charset=UTF-8",
  				error: function (xhr, ajaxOptions, thrownError) {  },
  				success: function(response) { }
  			});
  			
  		}
  	});
	
	resetModalDialog = function($modalDialog) {
		
		$modalDialog.find(".of-input-error").removeClass("of-input-error");
		$modalDialog.find("span.error").remove();
		
		var form = $modalDialog.find("form");
		
		if(form.data("action-orig") != undefined){
			form.attr("action", form.data("action-orig") + getRedirectParams());
		}
	};
	
	if(document.location.hash == "#add") {
		
		$("[data-of-toggled='addtodolist']").removeClass("of-hidden");
	}
	
	$("#taskListFilter, #membersFilter, #stateFilter").change(function (){
		//Reset and show every table row
		var shown = $("#shownTableRows");
		var filtered = $("#filteredTableRows");
		
		shown.find("tr.rowDetails").each(function() {
			$(this).remove();
		});
		
		filtered.find("tr[data-tasklistid]").each(function() {
			shown.append($(this));
		});
		
		//Member and Task state filtering
		var userID = $("#membersFilter").val();
		var state = $("#stateFilter").val();
		var hiddenCountT = 0;
		
		if(state == "" || state === "FINISHED"){
			getFinishedTasks();
		}
		
		var ignoreFinished = state == "AllWithoutFinished";
		
		if(userID != "" || state != "") {
			
			var showStateFilter = "";
			var showUserFilter = "";
			var hideStateFilter = "";
			var hideUserFilter = "";
			
			if(userID != undefined && userID != "") {
				showUserFilter = "[data-responsibleuser='" + userID + "']";
				hideUserFilter = "[data-responsibleuser!='" + userID + "']";
			}
			
			if(state != "") {
				if(state == "AllWithoutFinished"){
					hideStateFilter = ".FINISHED";
				} else {
					showStateFilter = "." + state;
					hideStateFilter = ":not(." + state + ")";
				}
			}
			
			$("ul.of-todo-list > li" + showUserFilter + showStateFilter).show();
			
			if(hideUserFilter != "") {
				$("ul.of-todo-list > li" + hideUserFilter).hide();
			}
			
			if(hideStateFilter != "") {
				$("ul.of-todo-list > li" + hideStateFilter).hide();
			}
			
			var invert = ignoreFinished;
			
			if(ignoreFinished){
				state = "FINISHED";
			}
			
			shown.find("tr[data-tasklistid]").each(function() {
				
				var task = $(this);
				
				if((userID != "" && task.data("responsibleuser") != userID) || (state != "" && invert == task.hasClass(state))){
					filtered.append(task);
					hiddenCountT++;
				}
			});
			
		} else {
			$("ul.of-todo-list > li").show();
		}
		
		if(ignoreFinished == true){
			state = ""; //Don't hide lists
		}
		
		//TaskList filtering
		var filterOn = $("#taskListFilter").val();
		var hiddenCountL = 0;
		
		$("div[data-tasklistid]").each(function() {
			
			var tasklist = $(this);
			
			//Always show selected list. Hide list if another filter is on and there are no results in the list
			if(tasklist.data("tasklistid") == filterOn || ((filterOn == undefined || filterOn === "") && ((userID == "" && state == "") ||
					tasklist.find("li[data-taskid]").not("[style*='display: none;']").length > 0))){
				tasklist.show();
			} else {
				tasklist.hide();
				hiddenCountL++;
			}
		});
		
		shown.find("tr[data-tasklistid]").each(function() {
			
			var task = $(this);
			
			if(filterOn !== "" && task.data("tasklistid") != filterOn){
				filtered.append(task);
				hiddenCountT++;
			}
		});
		
		//Notices
		var noticeL = $("#taskListFilterNotice");
		var noticeT = $("#taskTableFilterNotice");
		var listVisible = $("[data-of-toggled-multiple='list']").is(":visible");
		
		noticeL.children("span").text(hiddenCountL);
		noticeT.children("span").text(hiddenCountT);
		
		filterHasHiddenThings = hiddenCountL > 0 || hiddenCountT > 0;
		
		if(filterHasHiddenThings && listVisible == true){
			noticeL.show();
		} else {
			noticeL.hide();
		}
			
		if(filterHasHiddenThings && listVisible != true){
			noticeT.show();
		} else {
			noticeT.hide();
		}
		
		// Reload table sorter
		shown.parent().trigger('update');
	});
	
	$("a[data-of-toggler-multiple]").click(function(){
		var footer = $("#finishedTaskListsFooter");
		var noticeL = $("#taskListFilterNotice");
		var noticeT = $("#taskTableFilterNotice");
		
		noticeL.hide();
		noticeT.hide();
		
		tableSelected = $(this).data("of-toggler-multiple") == "table";
		
		if(filterHasHiddenThings){
			if(tableSelected){
				noticeL.hide();
				noticeT.show();
			} else {
				noticeL.show();
				noticeT.hide();
			}
		}
		
		if(tableSelected){
			footer.hide();
		} else {
			footer.show();
		}
	});
	
	$("tr[data-taskid]").click(function(){
		var row = $(this);
		
		var existing = row.next(".rowDetails");
		
		if(existing.length > 0){
			existing.remove();
		} else {
			var template = $("#rowDetailsTemplate").children().clone();
			
			template.find("span").text(row.data("description"));
			template.find("li.poster").text(i18nTaskModule.CREATED_BY + " " + row.data("poster"));
			template.find("li.posted").text(row.data("posted"));
			
			var editor = template.find("li.editor");
			var updated = template.find("li.updated");
			
			if(row.data("updated") != ""){
				editor.text(i18nTaskModule.EDITED_BY + " " + row.data("editor"));
				updated.text(row.data("updated"));
				
			} else {
				editor.remove();
				updated.remove();
			}
			
			row.after(template);
		}
	});
	
	if(previousTaskListFilter != undefined || previousMembersFilter != undefined || previousStateFilter != undefined){
		var taskListFilter = $("#taskListFilter");
		var membersFilter = $("#membersFilter");
		var stateFilter = $("#stateFilter");
		
		if(previousTaskListFilter != undefined){
			taskListFilter.val(previousTaskListFilter);
		}
		
		if(previousMembersFilter != undefined){
			membersFilter.val(previousMembersFilter);
		}
		
		if(previousStateFilter != undefined){
			
			if(previousStateFilter == "_"){
				stateFilter.val("");
			} else {
				stateFilter.val(previousStateFilter);
			}
			
		}
		
		taskListFilter.trigger("change");
	}
	
	window.setTimeout(function(){
		if(tableSelected){
			$("a[data-of-toggler-multiple='table']").trigger("click");
		}
	
		$("th.tablesorter-header").click(function(){
			//Remove row detail info when resorting
			var shown = $("#shownTableRows");
			
			shown.find("tr.rowDetails").each(function() {
				$(this).remove();
			});
		});
	}, 1);
	
});

function getRedirectParams(){
	var redirect = "&taskListFilter=" + $("#taskListFilter").val() + "&membersFilter=" + $("#membersFilter").val() + "&stateFilter=";
	var stateVal = $("#stateFilter").val();
	
	if(stateVal == ""){
		redirect += "_";
	}else{
		redirect += stateVal;
	}
	
	if(tableSelected){
		redirect += "&tableSelected"
	}
	
	if(hasFinishedTasks){
		redirect += "&withFinished"
	}
	
	return redirect;
}

function getFinishedTasks(){
	if(hasFinishedTasks !== true){
		window.location = taskModuleAlias + "?withFinished" + getRedirectParams();
	}
}