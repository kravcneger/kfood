class OrganizationsController < ApplicationController  
  before_action except: [:update] do 
    @organization = Organization.find(params[:id])
    if !@organization.published and !available_control?      
      respond_to do |format|
        format.html { render '_page_unavailable', layout: 'application' }
      end
    end     
  end   
  before_action :authenticate_organization!, except: [:show, :info]
  before_action :current_organization?, only: [:edit]

  layout 'organization'

  def show
    @category = !params[:category_id].nil? ? Category.find(params[:category_id]) : @organization.categories.first
    load_products  
    respond_to do |format|
      if request.xhr?       
        format.html { render 'categories/_products_list', layout: false }
      else
        load_catogories
        @basket = session["bascket_#{@organization.id}".to_sym] || Basket.new
        format.html { render 'menu' }
      end
    end
  end

  def info
    respond_to do |format|
      format.html { render 'info' }
    end
  end

  def edit
    @type = get_type_data
  end	

  def update
    @organization = current_organization
    if @organization.update(organization_params)
      flash[:success] = "Organization updated"
    else
      flash[:danger] = @organization.errors.full_messages
    end
    redirect_to edit_organization_path(@organization,get_type_data)
  end

  def destroy_map
    @organization = current_organization
    @organization.map_code = nil
    @organization.save(validate: false)
    redirect_to info_organization_path(@organization)
  end

  private

  def load_catogories    
    if available_control?
      @categories = @organization.get_menu(:all)
    else
      @categories = @organization.get_menu
    end
  end

  def load_products    
    if @category
      if available_control?
        @products = @category.products_all.orders(params[:order],params[:by])
      else
        @products = @category.products.orders(params[:order],params[:by])
      end  
    end
  end

  def organization_params
    case get_type_data
    when 'info'
      hash = [:avatar, :name, :additional_information, :description, :contacts, :addresses, :map_code]
      hash.delete(:map_code) if (params[:organization] and params[:organization][:map_code].blank?)
      params.require(:organization).permit(hash)
    when 'order'
      params.require(:organization).permit(:min_delivery, :delivery, :free_shipping)
    when 'notification'
      params.require(:organization).permit(:notification_email, :push_key1, :push_key2, :premature_notification)
    when 'auth'
      params.require(:organization).permit(:email,:password,:password_confirmation,:current_password)
    when 'social_networks'
      params.require(:organization).permit(social_networks: [:vk, :fb, :twitter])
    when 'block'      
      params.require(:organization).permit(:published, :message_block)  
    end
  end

  def get_type_data
    ['info','order','notification','auth','social_networks','block'].include?(params[:type]) ? params[:type] : 'info'
  end
end
