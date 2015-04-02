class BasketController < ApplicationController
  before_action do 
    @organization = Organization.find(params[:organization_id])
    @basket = session["bascket_#{@organization.id}".to_sym] || Basket.new
    @manager_order = ManagerOrder.new(@organization, @basket)
  end

  after_action do
    session["bascket_#{@organization.id}".to_sym] = @basket
  end
  
  def show
    respond_to do |format|
      format.html { render 'basket/_basket', layout: false }
      format.json { render json: @basket.to_json }      
    end    
  end

  def add_product
    product_str = params[:product_id]
    product_str += '_' + params[:addition_ids].join('_') if params[:addition_ids].present?

    if @manager_order.add_product(product_str, params[:count])
      status = 200
      response = @basket.to_json
    else
      status = 422
      response = @manager_order.errors[0]
    end
    respond_to do |format|
      format.json { render json: response, status: status }
    end
  end
  
  def set_number_product
    if @manager_order.set_number_product(params[:product_id], params[:count])
      status = 200
      response = @basket.to_json
    else
      status = 422
      response = @manager_order.errors[0]
    end
    respond_to do |format|
      format.json { render json: response, status: status }
    end    
  end

  def remove_product
    @manager_order.remove_product(params[:product_id])
    respond_to do |format|
      format.json { render json: @basket.to_json }
    end    
  end

  def remove_addition
    @manager_order.remove_addition(params[:product_id],params[:addition_id])
    respond_to do |format|
      format.json { render json: @basket.to_json }
    end    
  end

  def clear
    @manager_order.clear_basket
    respond_to do |format|
      format.json { render json: @basket.to_json }
    end      
  end

end
