Kfood.Collections.CategoriesCollection = Backbone.Collection.extend({

	model: Kfood.Models.Category,
	urlRoot : '/categories',
	paramRoot: 'category',

	done: function() {
		return this.where({done: true});
	},

	remaining: function() {
		return this.where({done: false});
	},

	load: function(active_item){
		var self = this;
		$.get('/categories/load_menu.html', function(data){
			$("#menu").html(data);
			$("#myModal").modal('hide');
			self.initiale_items();
			$('#menu, li[data-id="'+active_item.get('category_id')+'"], li[data-id="'+active_item.get('id')+'"]').addClass('active');
		});
	},
	
	initiale_items: function(){
		this.reset();    
		var self = this;
		$.each( $('li', $("#menu")), function(index,row){
			var model = new Kfood.Models.Category({id: $(row).data('id'), category_id: $(row).data('category_id'), 'active': !$(row).hasClass('off')});
			var cat = new Kfood.Views.CategoryRow({el: $(row), model: model});
			self.add(model);
		});
	}
});
