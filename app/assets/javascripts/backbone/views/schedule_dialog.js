Kfood.Views.SchedulesDialog = Kfood.Dialog.extend({
	events: {
		"click .edit_timetable": "openDialog",		
		"click .new_range": 'newRange',
		"click .set_holiday": 'setHoliday',
		"click .set_around": 'setAround',

	},
	
	openDialog: function(e){
		Kfood.Views.SchedulesDialog.__super__.openDialog.apply(this, new Array(e, Kfood.Views.SchedulesDialog.initialization ));
	},

	setHoliday: function(e){
		var day = $(e.target).closest('.form-group').data('day');
		$.post('/schedules/set_holiday',
			{day: day},
			Kfood.Views.SchedulesDialog.refresh
			);
	},

	setAround: function(e){
		var day = $(e.target).closest('.form-group').data('day');
		$.post('/schedules/set_around',
			{day: day},
			Kfood.Views.SchedulesDialog.refresh
			);
	},

	newRange: function(e){
		var day_row = $(e.target).closest('.form-group');
		var day = day_row.data('day');

		// Удалить все несохранённые диапазоны с формы
		$(".time_table_edit span.new.range").remove();
		// Показывать все скрытые теги b
		$('.time_table_edit .form-group > span > b').show();
		var model = new Kfood.Models.Schedule({day: day_row.data('day')});
		var view = new Kfood.Views.Schedule({model: model});
		if(day_row.find('.range').length > 0){
			day_row.find('span:first b').hide();
		}		
	},
},

{
	initialization: function(){
		Kfood.Schedules.initiale_items(); 
	},

	refresh: function(){
		$.get('/schedules/edit',
			function(response){		
				$('.time_table_edit').replaceWith(response);
				Kfood.Schedules.initiale_items();
				$.get('/schedules',
					function(response){		
						$('.timetable').replaceWith(response);
					});
			});		
	},

	renderErrors: function(text){
		$('.time_table_edit div.errors').html(text);
	},
});