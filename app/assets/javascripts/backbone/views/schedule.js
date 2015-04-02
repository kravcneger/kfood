Kfood.Views.Schedule =  Backbone.View.extend({
	events: {
		"click .glyphicon-remove:first": "destroy",
		"click .glyphicon-refresh:first": "save",
		"change input": "change",  
		"click input": "focus", 
	},

	initialize: function(){
		this.model.view = this;		
		this.render();		
	},

	save: function(e){    
		this.model.save({first_time: this.$el.find('input:first').val(), second_time: this.$el.find('input:last').val(), day: this.$el.closest('.form-group').data('day')},{
			dataType: 'json',
			success: function(model, response){
				Kfood.Views.SchedulesDialog.refresh();
			},
			error: function(model, response){ 
				Kfood.Views.SchedulesDialog.renderErrors(response.responseText);
				model.view.$el.addClass('invalid');
			},
		});
	},	

	destroy: function(){
		this.model.destroy({
			success: function(model, response){
				Kfood.Views.SchedulesDialog.refresh();
			},
			error: function(model, response){ 
				Kfood.Views.SchedulesDialog.renderErrors(response.responseText);
			},
		});
	},

	change: function(e){
		this.$el.addClass('changed');
	},

	focus: function(e){
		$(e.target).select();
	},

	render: function(){
		if(this.model.isNew()){
			var day_row = $(".time_table_edit div[data-day='"+this.model.get('day')+"']");
			$('<span class="new range"><input type="text" placeholder="00:00" />'+
				'<input type="text" placeholder="00:00" />' +	
				'<span class="glyphicon glyphicon-refresh"></span>' +
				'<span class="glyphicon glyphicon-remove"></span></span>').appendTo($('span:first',day_row));
			this.$el = $('span.new:last', day_row);		
		}
		this.$el.find("input[type='text']").inputmask("h:s");
	},
});