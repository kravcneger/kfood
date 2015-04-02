$(function(){	
	(function(){
		function Product(el,params){
			var self = this;
			this.$el = el;
			this.offset = this.$el.offset();

			this.id = params.id;		
			this.price = params.price;

			this.$el.on('click', '.add_product', addProduct);
			this.$el.on('click', 'small.product_additions', openAdditions);
			this.$el.on('mouseover', 'div.more', showMoreInformations);
			this.$el.on('click','.count', openCounter);

			function addProduct(e){
				$.post(Organization.add_product_path,
					{ product_id: self.id, count: self.count() },
					function(data){ 
						Basket.sync(data);
						Notification.success();
					})
				.fail(function(jqXHR){
					$.simplyToast(jqXHR.responseText, 'danger');
				});
				return false;
			}

			function openAdditions(e){
				AdditionBlock.openBlock(self);
				return false;
			}

			function showMoreInformations(e){
				if($(window).width() >= 700){
					var right = $(window).width() - self.offset.left - self.$el.outerWidth();
					var placement = self.offset.left > right ? 'left' : 'right';	

					self.$el.find('div.more').popover({ container: 'body', placement: placement, trigger: 'hover', viewport: self.$el});
					self.$el.find('div.more').popover('show'); 
				}
				return false;
			}

			function openCounter(){
				$('*').popover('destroy');
				div =  '<div style="width:120px;">'+
				'<div class="input-group input-group-xs" style="width:80px;margin-left:auto;margin-right:auto;" data-product_id="'+self.id+'">'+
				'<span class="input-group-btn input-group-xs">'+
				'<button type="button" class="btn btn-default btn-xs btn-number" data-type="minus" data-field="quant['+self.id+']">'+
				'<span class="glyphicon glyphicon-minus"></span>'+
				'</button>'+
				'</span>'+
				'<input style="width: 30px;" type="text" name="quant['+self.id+']" class="form-control input-xs input-number" value="'+self.count()+'" min="1" max="99">'+
				'<span class="input-group-btn">'+
				'<button type="button" class="btn btn-default btn-xs btn-number" data-type="plus" data-field="quant['+self.id+']">'+
				'<span class="glyphicon glyphicon-plus"></span>'+
				'</button>'+
				'</span>'+
				'</div>'+
				'</div>';
				$(this).popover({ title: 'Количество', html: true, content: div, placement: 'bottom', trigger: 'click'});
				$(this).popover('show');
				$('.popover.in .popover-title').append('<button type="button" class="close" onClick="$(\'.popover.in\').remove();">&times;</button>');
				return false;
			}
		}	

		Product.prototype = {
			load_additions: function(){
				var response = null; 	
				$.ajax({
					url: '/products/'+this.id+'/additions', 
					type: 'get',
					dataType: 'html',
					async: false,
					success: function(data){ response = data; }
				});
				return response;
			},
			count: function(){
				return parseInt(this.$el.closest('.product').find('.count > span:eq(0)').html());
			},
		};

		var AdditionBlock = (function(){
			$(document).on('change', '.additions_block input[type="checkbox"]', recalculate);
			$(document).on('change keyup', '.additions_block #count', recalculate);
			$(document).on('click', '.additions_block .btn-sm', submit);

			function submit(event){
				event.preventDefault();
				$.ajax({
					url: $('.additions_block form').attr('action'),
					type: 'post',
					data: $('.additions_block form').serialize(),
					dataType: 'json',
					success: function(data){ 
						closeBlock();
						Basket.sync(data);
						Notification.success();
					},
					error: function(jqXHR){
						$.simplyToast(jqXHR.responseText, 'danger');          
					}
				});
			}

			function recalculate(){
				var total = parseInt($('input#product_price').val());
				var price = 0;
				$('.additions_block input[type="checkbox"]').each(function() {       
					if($(this).is(':checked')){
						price += parseInt($.trim($(this).closest('.checkbox').find('.price_addition i:eq(0)').html()));
					}
				});

				var e_price = $('.additions_block .price i:eq(0)');
				var e_total = $('.additions_block .total i:eq(0)');
				e_price.html(price*$('.additions_block #count').val());
				e_total.html((total+price)*$('.additions_block #count').val());			
			}

			function closeBlock(){
				$('*').popover('destroy');
			}

			return {
				product: null,
				openBlock: function(product){
					this.product = product;
					closeBlock();
					this.product.$el.popover({ title: 'Добавки', html: true, content: this.product.load_additions(), placement: 'bottom', trigger: 'click'});
					this.product.$el.popover('show');

					if( this.product.offset.left > ($(window).width() - this.product.offset.left - this.product.$el.outerWidth()) && $(window).width() > 500){
						$('.popover.fade.in .arrow').css('margin-left',100);
						$('.popover.fade.in').css('margin-left',-110);
					}
					$('.popover.in .popover-title').append('<button type="button" class="close" onClick="$(\'.popover.in\').remove();">&times;</button>');
		  	//	window.scrollTo(this.product.offset.left, this.product.offset.top+100);
		  	return false;	
		  }
		}
	})();

	var Notification = {
		success: function(){
			$.simplyToast('Продукт добавлен', 'success', {delay: 2000});
		}
	};

	function ProductsCollection(){
		var products = [];
		return {
			load: function(){
				products = [];
				$.each($('.product'), function( index, value ) {
					products[index] = new Product($(this),{id: $(value).data('id')});
				});     	
			},
		};    
	}

	window.Products_module = new ProductsCollection;
	window.Products_module.load();

	$(window).on('resize', function(){
		window.Delay( 
			function(){ 
				window.location = window.location.pathname;
			}, 500);    
	});

})();
});

