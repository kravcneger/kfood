Kfood.Views.Position = Backbone.View.extend({
	events: {
		"change input[type='number']": 'recalculate',	
		"keyup input[type='number']": 'recalculate',		
		'click .remove_addition': 'remove_addition',
		'click .remove_position': 'remove_position',
		'mouseover .select_addition': 'loadAdditions',
		'change .select_addition': 'selectAddition'
	},

	initialize: function(options) {
		this.options = options;
		this.index_number = 0;
		if( $('input.index_number').length > 0  ){
			this.index_number = parseInt($('input.index_number:first').val())+1;
		}		
		this.render();
	},

	render: function(){
		var self = this;
		el = '';
		el += '<div class="position col-xs-12 col-sm-12">';
		el += '<h5 class="list-group-item-heading">' + this.options.position['name'] + ' ' + this.options.position['price']  + 'руб.<a class="remove_position">×</a></h5>';

		el += '<input type="hidden" class="index_number" value="'+this.index_number+'" />';
		el += '<input type="hidden" class="product_id" name="products['+this.index_number+'][id]" value="'+this.options.position['id']+'" />';
		el += '<input type="hidden" name="products['+this.index_number+'][name]" value="'+this.options.position['name']+'" />';
		el += '<input type="hidden" class="product_price" name="products['+this.index_number+'][price]" value="'+this.options.position['price']+'" />';
		el += '<input type="hidden" class="position_price" name="products['+this.index_number+'][all_price]" value="'+this.options.position['all_price']+'" />';

		if(this.options.position['additionals']){
			el += '<small class="list-group-item-text additions_list">';
			el += '<select class="select_addition"><option>Добавить добавку</option></select>';
			el += '</small>';
		}

		el += '<div class="col-xs-12 col-sm-12">';
		el += '<div class="col-xs-12 col-sm-10 count"><input type="number" min="1" max="99" name="products['+this.index_number+'][count]" value="'+this.options.position['count']+'" />';
		el += 'шт. </div><div class="col-xs-12 col-sm-2"><span class="price">' + this.options.position['all_price'] + '</span>руб.</div></div>';
		el += '</div>';

		this.$el = $(el);
		$('#order_products').prepend(this.$el);
		if(this.options.position['additionals']){
			$.each(this.options.position['additionals'], function( i, ad ){
				self.renderAddition(ad);
			});
		}
		this.recalculate();
	},

	renderAddition: function(ad){
		el = '<span class="addition">';
		el += ad['name'] + '(' + ad['price'] + 'р.)<a class="remove_addition">×</a><br /> ';		
		el += '<input type="hidden" class="addition" name="products['+this.index_number+'][additions][][price]" value="'+ad['price']+'" />';
		el += '<input type="hidden" class="add_name" name="products['+this.index_number+'][additions][][name]" value="'+ad['name']+'" />';
		el += '</span>';
		this.$el.find('.additions_list').prepend(el);		
	},

	loadAdditions: function(e){
		var self = this;
		$.get('/products/' + this.options.position['id']+ '/additions.json', function(data){					
			self.$el.find('.select_addition').html('<option>Добавить добавку</option>');
			$.each(data, function(i, ad){
				self.$el.find('.select_addition').append('<option value="'+ad['id']+'" data-name="'+ad['name']+'" data-price="'+ad['price']+'" >'+ad['name']+ ' ' +ad['price'] +'руб.</option>');
			});			
		});
		$(this.$el).off('mouseover', '.select_addition');
		return false;
	},  

	selectAddition: function(e){
		var opt =  $(e.target).find('option:selected');
		if( opt.attr('value') ){
			var addition = {name: opt.data('name'), price: opt.data('price')};
			this.renderAddition(addition);
			this.recalculate();
		}
	},

	remove_position: function(){
		this.$el.remove();
		Kfood.Views.Position.recalculateFinalData();
		return false;
	},   

	remove_addition: function(e){
		$(e.target).closest('.addition').remove();
		this.recalculate();
		return false;
	}, 

	recalculate: function(){
		var sum = parseInt(this.$el.find('.product_price').val());
		$.each( this.$el.find('input.addition'),  function( i, ad ){
			sum = sum + parseInt($(ad).val());
		});
		sum = sum *  parseInt(this.$el.find("input[type='number']").val());
		this.$el.find('.price').html(sum);
		this.$el.find('.position_price').val(sum);
		Kfood.Views.Position.recalculateFinalData();
	},

	_get_number: function(){
		return this.number;
	},

},
{
	recalculateFinalData: function(){
		var sum = 0;
		$.each( $('.position .position_price'),  function( i, pr ){
			sum +=  parseInt($(pr).val());
		});

		var delivery = parseInt(Organization.delivery);
		if ( sum >= parseInt(Organization.free_shipping) ){
			delivery = 0;
		}
		var final_price = sum + delivery;
		$('input#price').val(sum);
		$('input#delivery').val(delivery);
		$('.final_data .final_price span').html(final_price);
	}
});
