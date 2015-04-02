Kfood.Models.Category = Kfood.TreeElement.extend({
 	urlRoot : '/categories',
 	paramRoot: 'category',

 	defaults: function() {
 		return {
 		};
 	},

  _entity_method: function(){
    return 'category_id';
  },

  _get_collection: function(){
    return Kfood.Categories;
  }, 
  
  _entity_type: function(){
    return 'categories';
  },

  _entity_name: function(){
    return 'категорию';
  },

 });