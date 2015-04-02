Kfood.Collections.AdditionsCollection = Backbone.Collection.extend({

	model: Kfood.Models.Addition,
	urlRoot : '/additions',
	paramRoot: 'addition',

	done: function() {
		return this.where({done: true});
	},

	remaining: function() {
		return this.where({done: false});
	},

	load: function(active_item){
		var self = this;
		$.get('/additions/'+Organization.id+'/index.html', function(data){
			$("#myModal .modal-body").html(data);
			self.initiale_items();
			$('#additions, li[data-id="'+active_item.get('addition_id')+'"], li[data-id="'+active_item.get('id')+'"]').addClass('active');
		});
	},

	initiale_items: function(){
    this.reset();
    var self = this;
		$.each( $('li', $("#additions")), function(index,row){
			var model = new Kfood.Models.Addition({id: $(row).data('id'), addition_id: $(row).data('addition_id'), 'active': !$(row).hasClass('off')});
			var addition = new Kfood.Views.AdditionRow({el: row, model: model});
			self.add(model);
		});		
	},
});