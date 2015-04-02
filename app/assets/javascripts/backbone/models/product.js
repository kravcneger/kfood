Kfood.Models.Product = Backbone.Model.extend({
	urlRoot : '/products',

	defaults: function() {
		return {
		};
	},

	_entity_method: function(){
		return 'product_id';
	},

	_get_collection: function(){
		return Kfood.Products;
	}, 

	_entity_type: function(){
		return 'products';
	},

	_entity_name: function(){
		return 'продукт';
	},

});

