	Kfood.Views.OrderDialog = Backbone.View.extend({		
		_model: null,

		initialize: function(options) {
			this.options = options;
			$(document).on('keyup', '#search_product', this.searchProduct);
			$(document).on('submit', '#admin_order', this.save);

			$(document).on('click', '.list_orders .more a.btn.btn-primary', this.openOrder);
			$(document).on('click', '.detected_product', this.addProduct);
			$(document).on('click', 'ul.status li', Kfood.Views.OrderDialog.changeStatus );
			$(document).on('click', '.btn.destroy, .btn.restore', Kfood.Views.OrderDialog.destroy);
			$(document).on('click', 'a#recalculate', Kfood.Views.Position.recalculateFinalData);	
			$(document).on('change keyup','input#price, input#delivery', function(e){
				$('.final_price span').html( parseInt($('input#price').val()) + parseInt($('input#delivery').val()) );
			});
		},

		openOrder: function(e){
			var target = $(e.target).attr("href");
			var tr = $(e.target).closest('tr.ord');
			
			this._model = new Kfood.Models.Order;
			this._model.fetch({dataType: 'json', url: target, async: false});
			
			if(this._model.get('viewed')){
				tr.removeClass('active');
			}

			$('#orderDialog').modal('show');

			Kfood.Views.OrderDialog.clearResult();			
			$('#admin_order').attr('action','/admin/orders/' + this._model.get('id')); 

			$('.admin_order .errors').html(''); 
			$('#name').val(this._model.get('name')); 
			$('#contact_phone').val(this._model.get('contact_phone')); 
			$("#contact_phone").inputmask("+7(999)-999-99-99");

			$('#street').val(this._model.get('street')); 
			$('#house').val(this._model.get('house')); 
			$('#building').val(this._model.get('addition_info')['building']); 
			$('#apartment').val(this._model.get('addition_info')['apartment']);
			$('#entrance').val(this._model.get('addition_info')['entrance']);
			$('#floor').val(this._model.get('addition_info')['floor']);
			$('#access_code').val(this._model.get('addition_info')['access_code']);
			$('#renting').val(this._model.get('addition_info')['renting']);
			$('#time_order').val(this._model.get('time_order'));
			$("#time_order").inputmask("9999-99-99 99:99");
			$('.time_order').datetimepicker({language: 'ru'});

			$('#comment').val(this._model.get('comment'));

			$('#orderDialog #order_products').html('');
			var positions = [];
			if(this._model.get('body')['products']){
				$.each(this._model.get('body')['products'], function( i, pr ) {
					positions[i] = new Kfood.Views.Position({position: pr});
				});
			}

			var final_row = '<div class="final_data">';
			final_row += '<a id="recalculate">пересчитать</a>';
			final_row += '<h5 class="price">Стоимость заказа: <input name="price" id="price" style="width:60px;" value="' + this._model.get('price')+ '" />руб.</h5>';
			final_row += '<h5 class="delivery">Стоимость доставки: <input name="delivery" id="delivery" style="width:60px;" value="' + this._model.get('delivery')+ '" />руб.</h5>';
			final_row += '<h4 class="final_price">Общая сумма: <span> ' + (this._model.get('price') + this._model.get('delivery'))+ '</span>руб.</h4>';
			final_row += '</div>';

			$('#orderDialog #order_products').append(final_row);		
			return false;	
		},

		searchProduct: function(e){			
			window.Delay(function(){
				var query = $(e.target).val();
				$('#search_result').html('');
				if (query != ''){
					$.get('/products/search?organization_id='+Organization.id+'&query='+ query, function(data){					
						$.each(data, function(i, pr){
							$('#search_result').append('<a href="#" data-id="'+pr['id']+'" class="list-group-item detected_product">' + pr['name'] + ' ' + pr['price'] +'руб.</a>');
						});
					});
				}
			},500);
			$('#search_result').focus();
		},

		addProduct: function(e){
			e.preventDefault();
			var product_model = new Kfood.Models.Product({id: $(e.target).data('id')});
			product_model.fetch({dataType: 'json', async: false});

			var position = { 
				id: product_model.get('id'),
				name: product_model.get('name'),
				price: product_model.get('price'),
				count: 1,
				all_price: product_model.get('price'),
			};

			if( product_model.get('addition_id') ){
				position['additionals'] = {};
			}

			new Kfood.Views.Position({position: position});
			Kfood.Views.OrderDialog.clearResult();
			return false;
		},

		save: function(e){
			var self = this;
			$.ajax({
				type: 'PUT',
				dataType: 'json',
				url: $(e.target).attr('action'),
				data: $(e.target).serialize(),
				success: function(model)
				{
					$('#orderDialog .errors').html('');
					$('#orderDialog').modal('hide');
					$.simplyToast("Изменения сохранены", 'success');
					Kfood.Views.OrderDialog.refreshRow(model);
				},
				error: function(jqXHR){
					// $.simplyToast(jqXHR.responseText, 'danger');
					$('.admin_order .errors').html('<p class="text-danger">'+jqXHR.responseText+'</p>');  
					if($(window).width() < 768){
						$('#orderDialog').animate({scrollTop: 0}, 300);
					}   
				},
			});
		},

	},
	{		
		changeStatus: function(e){
			var order_model = new Kfood.Models.Order({id: $(e.target).closest('tr.ord').data('id')});
			order_model.fetch({async: false});
			order_model.save({status: $(this).data('status')},{dataType:'json', 
				success: function(model){ Kfood.Views.OrderDialog.refreshRow(model.attributes); }
			});
		},

		destroy: function(e){
			var tr = $(e.target).closest('tr.ord');
			var order_model = new Kfood.Models.Order({id: tr.data('id')});
			order_model.destroy({
				dataType: "json",
				success: function(model){ $("tr.ord[data-id='"+model.get('id')+"']").remove(); },
			});
		},

		clearResult: function(){
			$('#search_product').val('');
			$('#search_result').html('');
		},

		refreshRow: function(model){
			var tr = $("tr.ord[data-id='"+model.id+"']");
			tr.find('td:eq(0)').html(model.name);
			tr.find('td:eq(1)').html(model.contact_phone);
			tr.find('td:eq(2)').html(model.price+' руб.');

			tr.find('td:eq(3)').html(model.time_order ? model.time_order.substr(5,11).replace(/T/, ' ') : '');
			var text = ['Не просмотрен', 'Принят', 'Выполнен'][parseInt(model.status)];
			var cl = ['btn-danger', 'btn-info', 'btn-success'][parseInt(model.status)];
			tr.find('.btn-group button .text').text(text);
			tr.find('.btn-group button').attr('class','btn btn-xs dropdown-toggle '+cl);
		}
	});

