Kfood.Views.AdditionsDialog = Kfood.Dialog.extend({
	events: {
		"click #show_additions, #new_addition, #close_addition": "openDialog",
		"click #save_addition": "saveAddition",
		"change #addition_addition_id": "changeAddition",
	},
	
	openDialog: function(e){
	  Kfood.Views.AdditionsDialog.__super__.openDialog.apply(this, new Array(e, function(){ Kfood.Additions.initiale_items();} ));
	},

	saveAddition: function(e){
		var hash = $('#addition_form').serializeJSON()['addition'];
		var addition;
		if(hash.id){
			addition =  Kfood.Additions.get(hash.id);
		}
		else{
			addition = new Kfood.Models.Addition;
		}
		addition.save(hash, {
			success: function(model,response){
				Kfood.Additions.load(model);         
			},
			error: this._render_errors
		});
	},
  
  changeAddition: function(e){
    if( $('#addition_addition_id').val() == '0'){
    	$('.price-row').hide();
    }else{
    	$('.price-row').show();
    }    
  },

});