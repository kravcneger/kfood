Kfood.Collections.ProductsCollection = Backbone.Collection.extend({

	model: Kfood.Models.Product,
	urlRoot : '/products',
	paramRoot: 'product',

	initiale_items: function(){
		this.reset();
		var self = this;
		$.each( $('.product'), function(index,row){
			var model = new Kfood.Models.Product({id: $(row).data('id') });
			var product = new Kfood.Views.ProductView({el: $(row), model: model});
			self.add(model);
		});		
	},

	refreshProduct: function(id){
		this.get(id).fetch({dataType: 'html',    
			success: function(model,response) {
				var el = $(".product[data-id='"+model.id+"']");
        // Проверяем category_id категории которая коткрыта и id категория обновляемого продукта
        // Если category_id одинаковые обновляем блок с продуктом , иначе удаляем
        if( $('#self_category_id').val() == model.get('category_id') ){
        	el.replaceWith(response);
        	var product = new Kfood.Views.ProductView({el: $(".product[data-id='"+model.get('id')+"']"), model: model});
        }else{
        	el.remove();
        }
      },
    });    
	},
});