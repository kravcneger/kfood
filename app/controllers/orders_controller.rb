class OrdersController < ApplicationController
  helper TimeRanger

  before_action do 
    @organization = Organization.find(params[:organization_id])
    @basket = session["bascket_#{@organization.id}".to_sym] || Basket.new
    @manager_order = ManagerOrder.new(@organization, @basket)
  end

  def show
    @order = Order.new(organization_id: @organization.id)
    respond_to do |format|
      format.html { render 'orders/_make_order', layout: false }
    end    
  end

  def create
    p = order_params
    
    if params[:order]
      if params[:order][:to_checkbox] == '1'
        begin
          t = params[:order][:to_day].split('-') 
          p[:time_order] = Time.new( t[0], t[1], t[2], params[:order][:to_hours], params[:order][:to_minutes], 0 ).to_s(:db)
        rescue
          p[:time_order] = nil
        end
      end
    end
    
    # Deletes unnecessary characters
    p[:ip] = request.remote_ip
    number_with_mask = p[:contact_phone].clone
    p[:contact_phone].gsub!(/[^\d]/,'')

    if @manager_order.to_order(p)    
      status = 200
      response = :ok    
      if Rails.env.production?
        us = []
        us.push(@organization.push_key1) if @organization.push_key1.present?
        us.push(@organization.push_key2) if @organization.push_key2.present?
        us.each do |u|
          Pushover.notification(message: "Заказ от #{number_with_mask}", title: 'Новый заказ', user: u)
        end
      end
    else 
      status = 422
      response = {}
      @manager_order.errors.each_with_index do |v,i|
        response[i] = v
      end
    end
    respond_to do |format|
      format.json { render json: response.to_json, status: status }
    end       
  end

  private

  def order_params
    fields = [:name, :contact_phone, :street, :house, :building, :apartment, :entrance, :floor, :access_code, :renting, :comment]
    params.require(:order).permit(fields).merge(organization_id: @organization.id, body: @basket)
  end  

end
