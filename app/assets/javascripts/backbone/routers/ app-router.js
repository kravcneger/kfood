Kfood.Routers.AppRouter = Backbone.Router.extend({

	routes: { 
		":id/:category_id":  "load_products",  
		":id/:category_id/:order":  "load_products",  
		":id/:category_id/:order/:by":  "load_products",  
	},

	load_products: function(id,category_id, order, by) {
		$('.content').html('');
		var href =  Organization.organization_path+'/'+category_id;
		var params = [];

		if(order){ 
			params.push(order);			
		}
		if(by){
			params.push(by);
		}
		if(params.length > 0){
			href += '/' + params.join('/');
		}

		$('.content').load( href, function(){
			var cat = $("#menu li[data-id='"+category_id+"']");
			$("#menu li").removeClass('active');
			$(cat).parents('li').addClass('active');
			$(cat).addClass('active');			

			if(order){ 
				$('#self_category_order').val(order);
				var b = $(".sorter a."+order);
				if(by == 'asc' || by == null){
					b.attr('href', b.attr('href')+"/desc");
					b.removeClass('asc');
					b.addClass('desc');
				}else{
					b.removeClass('desc');
					b.addClass('asc');			
				}
			}

			Products_module.load();
			if(typeof Kfood.Products != 'undefined'){
				Kfood.Products.initiale_items();
			}
			if($(window).width() < 768){
				$('html, body').animate({scrollTop: $(".content").offset().top - 100}, 300);
			}
		}); 
	},

});