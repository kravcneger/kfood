(function(global){
	function BasketModule(){
		var self = this,
		products = {},
		price = 0,
		delivery = 0;

		$(document).on('click','.open_basket',function(e){
			Basket.open();
			return false;
		});

		$(document).on('change keyup',".product_position input[type='number']",setNumberProduct);
		$(document).on('click','.clear_basket',clearBasket);

		$(document).on('click','a.remove_product',function(e){
			var product_id = $(this).data('id');
			$.ajax({
				url: Organization.remove_product_basket_path,
				success: function(data){ 
					$("a.remove_product[data-id='"+product_id+"']").closest('.product_position').remove();
					Basket.sync(data);
				},
				data: {product_id: product_id},
				method: 'post',
				dataType: 'json',
				async: false,
			});

			return false;
		});

		$(document).on('click','.remove_addition',function(e){			
			var a_id = $(this).data('id');
			var p_id = $(this).closest('.product_position').data('id');
			$.ajax({
				url: Organization.remove_addition_organization_basket_index_path,
				success: function(data){ 
					Basket.sync(data);
					Basket.open();
				},
				data: {product_id: p_id, addition_id: a_id},
				method: 'post',
				dataType: 'json',
				async: false,
			});

			return false;
		});

		function setNumberProduct(e){
			var pr_position = $(e.target).closest('.product_position');
			var product_id =  pr_position.data('id');
			var count = $(e.target).val();
			$.post(Organization.set_number_product_organization_basket_index_path,
				{ product_id: product_id, count: count },
				function(data){
					pr_position.find('.price > span:eq(0)').html(data['products'][product_id]['all_price']);
					Basket.sync(data); 
				});
			return false;
		}
    
    function clearBasket(e){
			$.post(Organization.clear_organization_basket_index_path,{},
				function(data){
					Basket.sync(data); 
				});
			return false;    	
    }

		function render(){
			render_panel();
			render_basket();
		}

		function render_panel(){
			$('#basket_panel .price b').html(price + ' + ' + delivery);
			if(price == 0){
				$('#basket_panel').css('display','none');
			}else{
				$('#basket_panel').css('display','block');
			}
		}

		function render_basket(){
			$('#custom .order_info > div:eq(0) > span > b').html(price);
			$('#custom .order_info > div:eq(1) > span > b').html(delivery);
			$('#custom .order_info > div:eq(2) > h3 > b').html(price + delivery);
		}

		return {
			sync: function(basket){
				if(!basket){
					$.ajax({
						url: Organization.organization_basket_index_path,
						success: function(data){ basket = data; },
						method: 'get',
						dataType: 'json',
						async: false,
					});
				}
				products = basket.products;
				price =  basket.price;
				delivery = basket.delivery;
				render();
				if(price <= 0){
					this.close();
				}
			},

			open: function(){
				var title       =   '.modal-title',
				content     =   '.modal-body',
				dataRemote  =   'a[data-remote=true]',
				toolbar     =   'div.modal-footer',
				modal       =   '#custom';

				$(title).html('Корзина');
				$.ajax({
					url: Organization.organization_basket_index_path,
					success: function(basket){ 
						$(content).html(basket);
						$(modal).modal("show"); 
					},
					method: 'get',
					dataType: 'html',
				});
			},

			close: function(){
				$('#custom').modal('hide'); 
			}
		};		
	}

	global.Basket = new BasketModule;

})(this);




