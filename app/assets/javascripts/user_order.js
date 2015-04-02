$(function(){	
	(function(global){
		function OrderModule(){
			var self = this;			
			
			$(document).on('click','.go-to-second-step', open);
			$(document).on('change', "input[name='order[to_checkbox]']",propRowData );
			$(document).on('click','.to-order', createOrder);

			function open(e){
				var title       =   '.modal-title',
				content     =   '#custom .modal-body .first-step',
				modal       =   '#custom';

				$.ajax({
					url: Organization.orders_path,
					success: function(order){ 
						$(title).html('Заказ');
						$(content).replaceWith(order);
						$(e.target).removeClass('go-to-second-step');
						$(e.target).addClass('to-order');
						$("#order_contact_phone").inputmask("+7(999)-999-99-99");
					},
					method: 'get',
					dataType: 'html',
				}); 
				return false;    	
			}

			function createOrder(e){
				e.preventDefault();
				var form = $('#new_order');
				$.ajax({
					type: 'post',
					dataType: 'json',
					url: form.attr('action'),
					data: form.serialize(),					
					success: function(data) {
						Basket.sync();
						$.simplyToast("Ваш заказ принят.Скоро наш администратор свяжется с вами.", 'success'); 
					},
					error: function(jqXHR,textStatus,errorThrown){
						var response = jQuery.parseJSON(jqXHR.responseText);
						var msg = '';
						$.each(response, function(i, r){           
							msg += r + '<br />'; 
						});
						$('#custom .errors').html('<p class="text-danger">'+msg+'</p>');  
						if($(window).width() < 768){
							$('#custom').animate({scrollTop: 0}, 300);
						}   
					},
				});				
				return false;
			} 

			function propRowData(e){
				if( $(e.target).val() == '1' )
					$('.row_order_to').show();
				else
					$('.row_order_to').hide();			
			}

			function orderFormSubmit(e){
				$('#order_form').submit();
			}
		}


		window.Order = new OrderModule;


	})();
});




