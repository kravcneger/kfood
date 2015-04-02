Kfood.Collections.SchedulesCollection = Backbone.Collection.extend({

	model: Kfood.Models.Schedule,
	urlRoot : '/schedules',
	paramRoot: 'schedule',
  
	initiale_items: function(){
    this.reset();
    var self = this;
		$.each( $('.range', $(".time_table_edit")), function(index,row){
			var model = new Kfood.Models.Schedule({id: $(row).data('id'), day: $(row).closest('.form-group').data('day'), first_time: $(row).find('input:first').val(), second_time: $(row).find('input:last').val() });
			var schedule = new Kfood.Views.Schedule({el: $(row), model: model});
			self.add(model);
		});		
	},
});