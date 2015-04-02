Kfood.Views.ProductsDialog = Kfood.Dialog.extend({
	events: {
		"click #new_product": "openDialog",
		"click .remove_image": "removeImage",
    "click .refresh_image": "imageBlockProp",
    "change #product_active": "changeActive",
  },

  saveProduct: function(event){

  },
  
  removeImage: function(e){
    if(confirm('Вы уверены что хотите удалить изображение?')) {
      var self = this;
      var id = $('#product_id').val();
      $.post('/products/destroy_image',{id: id},
       function(data, textStatus, jqXHR){
        $('.upload_file').show();
        $('.uploaded_file').hide();
        $('.refresh_image').remove();   
        $('.upload_file br').remove(); 
        Kfood.Products.refreshProduct(id); 
      });
    }
  },

  changeActive: function(e){
    if( $('#product_active').val() == '2'){
    	$('.time_locked_to').show();
    }else{
    	$('.time_locked_to').hide();
    }    
  },

  imageBlockProp: function(){
    var up = $('.upload_file');
    var uped = $('.uploaded_file');
    if( $(up).css('display') == 'none' ){
      $(up).show();
      $(uped).hide();
    }
    else{
      $(up).hide();
      $(uped).show();     
    }
  },

});