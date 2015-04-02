//= require_self
//= require ./backbone/model
//= require ./backbone/view
//= require_tree ./backbone/templates
//= require_tree ./backbone/models
//= require_tree ./backbone/views

//= require ./jquery.serializeJSON.min.js
//= require jquery.remotipart

$(function(){
	Kfood.Additions = new Kfood.Collections.AdditionsCollection;	
	Kfood.Schedules = new Kfood.Collections.SchedulesCollection;
	window.Dialog = new Kfood.Dialog();
	window.additions_dialog = new Kfood.Views.AdditionsDialog({el: $("body")});
	window.schedule_dialog = new Kfood.Views.SchedulesDialog({el: $("body")});

	$('[data-toggle="tooltip"]').tooltip();
	$('[data-toggle="modal tooltip"]').tooltip();
});