Kfood.View = Backbone.View.extend({});


Kfood.ItemRow = Backbone.View.extend({
  events: {
    "click .glyphicon-remove:first": "removetElement",
    "click .toggle_publish:first": "toggle",
    "click .glyphicon-pencil:first": "editElement",    
  },

  initialize: function(){   
    this.listenTo(this.model, 'sync', this._publish_status_set); 
    this.model.view = this;
    this.renderControl();
  },

  render: function() {
    return this;
  },
  
  removetElement: function(e){
    var self = this;
    if(confirm('Вы уверены что хотите удалить '+this.model._entity_name()+'?')) {
      this.model.destroy({
        success: function(model, data){ self.$el.remove(); },
        error: function(model, data){ if(data.status == 409) alert(data.responseText); },
      });
    }    
    e.stopPropagation(); 
    return false; 
  },

  toggle: function(e){    
    var self = this;
    if( this.model.is_sub() && this.model.parent().get('active') == false ){
      alert('Для операции необходимо опубликовать родительскую категорию');
      return;
    }
    this.model.save({active: !this.model.get('active')},
    {
      success: function(model, data){
        self._publish_status_set();
        // Обновляем дочерние модели
        if(!self.model.get('active')){
          $.each( $(self.$el).find('li'), function(index, value){
            self.model._get_collection().get($(value).data('id')).fetch();
          });
        }
      },
      error: function(model, data){ alert(data.responseText); },
    });   
    e.stopPropagation(); 
    return false;  
  },
  
  renderControl: function(){
    this.$el.find('.toolbar:first').html('<span data-toggle="tooltip" title="удалить" class="glyphicon glyphicon-remove"></span>' +
      '<span data-toggle="modal tooltip" href="/'+this.model._entity_type()+'/'+this.model.get('id')+'/edit" data-target="#myModal" title="изменить" class="glyphicon glyphicon-pencil"></span>' +
      '<span data-toggle="tooltip" title="" class="glyphicon toggle_publish"></span>');
    this._publish_status_set();
    return this;
  },

  editElement: function(e, function_initiale){
    window.Dialog.openDialog(e, function_initiale);
    e.stopPropagation(); 
    return false; 
  },

  _publish_status_set: function(){
    if(this.model.get('active')){
      this.$el.removeClass('off');
      this.$el.find('.toggle_publish:first').addClass('glyphicon-eye-close').removeClass('glyphicon-eye-open');
      this.$el.find('.toggle_publish:first').prop('title', 'снять с публикации').tooltip();
    }else{
      this.$el.addClass('off');
      this.$el.find('.toggle_publish:first').addClass('glyphicon-eye-open').removeClass('glyphicon-eye-close');
      this.$el.find('.toggle_publish:first').prop('title', 'опубликовать').tooltip();
    }   
  },
});


Kfood.Dialog = Backbone.View.extend({    
  events: {
    //    'click *[data-target="#myModal"]': "openDialog",    
  },
  openDialog: function(e, function_initiale){
    e.preventDefault();
    var target = $(e.target).attr("href");
    $("#myModal .modal-body").empty();
    $("#myModal .modal-body").load(target, function() { 
      $("#myModal").modal("show");
      if(typeof function_initiale != "undefined"){
        function_initiale();
      }
    });
    e.stopPropagation();
    return false;
  },
  _render_errors: function(model,response){
    var msg = '';
    var data = $.parseJSON(response.responseText);
    $.each(data, function(index, value){
      $.each(value, function(i, r){           
        msg += r + '<br />'; 
      });           
    });
    $('.errors').html('<p class="text-danger">' + msg + '</p>');      
  },    
});
