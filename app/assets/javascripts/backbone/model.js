Kfood.TreeElement = Backbone.Model.extend({
	is_sub: function(){
		return !!this.get(this._entity_method());     
	},

	parent: function(){
		return this._get_collection().get(this.get(this._entity_method()));
	}
});
