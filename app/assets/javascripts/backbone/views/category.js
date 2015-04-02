Kfood.Views.CategoryRow = Kfood.ItemRow.extend({
	events: function(){
		return _.extend({},Kfood.ItemRow.prototype.events,{
			'click': 'navigate',
		});
	},

	navigate: function(e){
		e.stopPropagation();
		var href = this.$el.find('a:first').attr('href');
		window.app_router.navigate(href, true);	
		e.preventDefault();    
	},
});
