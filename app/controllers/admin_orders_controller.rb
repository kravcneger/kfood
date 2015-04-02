class AdminOrdersController < ApplicationController
  before_action :authenticate_organization!
  layout 'orders'
  
  before_action do 
    @organization = current_organization     
  end

  def index
    where = {}
    if params[:type].blank?
      where[:status] = 0..2
      @type = nil
      @orders = @organization.orders.where(where).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
    elsif params[:type] == 'time_order'
      @type = 'time_order'   
      @orders = @organization.premature_orders.paginate(:page => params[:page], :per_page => 20)  
    elsif params[:type] == 'basket'
      where[:status] = 3
      @type = 'basket'
      @orders = @organization.orders.where(where).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @orders } 
    end
  end

  def show
    @order = @organization.orders.where(id: params[:id].to_i).first
    unless @order.viewed?
      @order.update({viewed: true, notified: true})
    end
    respond_to do |format|
      format.json { render json: @order }
    end
  end

  def update
    @order = @organization.orders.find(params[:id])

    p = order_params
    products = {}
    if params[:products].present?
      params[:products].each do |key, row|
        products[key] = {id: row[:id], price: row[:price], name: row[:name], count: row[:count], all_price: row[:all_price]}
        if params[:products][key][:additions]
          products[key][:additionals] = {}
          params[:products][key][:additions].each_with_index do |a, i|            
            products[key][:additionals][i] = {name: a[:name], price: a[:price]}
          end
        end
      end
    end
    p[:body] = {}
    p[:body][:products] = products
    p[:contact_phone].gsub!(/[^\d]/,'')

    if @order.update(p)
      status = 200
      response = @order
    else
      status = 422
      response = @order.errors.full_messages.join("<br />") 
    end

    respond_to do |format|
      format.json { render json: response, status: status }
    end
  end

  def destroy
    @order = @organization.orders.find(params[:id])   
    status = @order.status == 3 ? 0 : 3  
    response_status =  @order.update({status: status, viewed: true}) ? '204' : '422'    

    respond_to do |format|
      format.json { render nothing: true, status: response_status }
    end    
  end

  def statistics
    @unviewed = @organization.orders.where(viewed: false, time_order: nil).count
    @unnotified = @organization.orders.where('orders.notified = false and orders.created_at >= :time', time: Time.zone.now-10.seconds )
    @premature_orders = @organization.premature_orders.count

    respond_to do |format|
      format.json { render json: {unviewed_count: @unviewed, unnotified_ids: @unnotified.ids} }
    end      
  end

  private

  def order_params    
    params.permit(:name, :contact_phone, :street, :house, :building, :apartment, :entrance, :floor, :access_code, :renting, :price, :delivery, :time_order, :status, :comment)
  end

end
