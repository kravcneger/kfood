Kfood.Views.ProductView = Kfood.ItemRow.extend({
	events: {
		'click span[data-target="#myModal"]': "editElement",    
		"click .glyphicon-remove:first": "removetElement",
		'click .btn-danger': 'publish',
	},

	initialize: function(){   
		this.model.view = this;
		this.renderControl();
	},

	editElement: function(e){  
		e.preventDefault();
		this.model.fetch({
			success: function(model, response){
				Kfood.Views.ProductView.__super__.editElement.apply(this,new Array(e));
			},
		});
		e.stopPropagation();
	},

	removetElement: function(e){
		if(confirm('Вы уверены что хотите удалить продукт?')) {
			var self = this;
			this.model.destroy({
				success: function(){	
					self.$el.parent().hide(function(){
						$(this).remove();
					});
				},
			});
		}
	},

	publish: function(){
		this.model.save({active: 1},{dataType: 'script'});
	},

	renderControl: function() {
		this.$el.append('<div class="toolbar"></div>');
		this.$el.find('.toolbar').html('<span data-toggle="modal" href="/products/'+this.model.get('id')+'/edit" data-target="#myModal" title="изменить" class="glyphicon glyphicon-pencil"></span>' +
			'<span data-toggle="tooltip" title="" data-placement="bottom" class="glyphicon glyphicon-remove"></span>');
		return this;
	},
});

