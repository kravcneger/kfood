Kfood.Models.Addition = Kfood.TreeElement.extend({
 	urlRoot : '/additions',
 	paramRoot: 'addition',

 	defaults: function() {
 		return {
 		};
 	},

 	_entity_method: function(){
 		return 'addition_id';
 	},

 	_get_collection: function(){
 		return Kfood.Additions;
 	}, 

 	_entity_type: function(){
 		return 'additions';
 	},

 	_entity_name: function(){
 		return 'добавку';
 	},
 });


 