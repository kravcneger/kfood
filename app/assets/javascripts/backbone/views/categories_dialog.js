	Kfood.Views.CategoriesDialog = Kfood.Dialog.extend({		
		events: {	
		  "click .new_cat": "openDialog",		  
			"click #save_category": "saveCategory",
		},
		initialize: function(){ 
			Kfood.Categories.initiale_items();
		},

		saveCategory: function(e){
			var hash = $('#category_form').serializeJSON()['category'];
			var cat;
			if(hash.id){
				cat =  Kfood.Categories.get(hash.id);
			}
			else{
				cat = new Kfood.Models.Category;
			}
			cat.save(hash,{
				success: function(model,response){
					Kfood.Categories.load(model);         
				},
				error: this._render_errors
			}); 
		},
	});