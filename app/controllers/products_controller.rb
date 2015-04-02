class ProductsController < ApplicationController
  before_action :authenticate_organization!, except: [:additions]
  before_action :is_ajax?
  before_action :set_product, only: [:show, :edit, :update, :destroy_image, :destroy]

  def show
    respond_to do |format|
      format.html { render partial:  'products/product', status: 200, locals: {product: @product} }
      format.json { render json: @product, status: :ok }
    end
  end

  # GET /products/new
  def new
    @product = Product.new(organization_id: current_organization.id)
    respond_to do |format|
      format.html { render 'form', layout: false }
    end
  end

  def create
    @product = Product.new(product_params)
    @product.save
    @category_id = @product.category_id
    respond_to do |format|
      format.js { render 'save' }
    end  
  end 

  def edit
    respond_to do |format|
      format.html { render 'form', layout: false }
    end  
  end

  def update
    @category_id = @product.category_id
    @product.update(product_params)
    respond_to do |format|
      format.js { render 'save' }
    end    
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.js { render nothing: true, :status => 204  }  
    end
  end

  def destroy_image
    @product.avatar = nil
    respond_to do |format|
      format.html { render nothing: true, :status => @product.save ? 200 : 400  }  
    end 
  end
  
  def search 
    w = []
    if params['organization_id'].present?
      w.push("organization_id = #{params['organization_id'].to_i}")
    end
    w.push('LOWER(name) like ? and (active=1 or active=2)')

    @products = Product.select('id, addition_id, name, price').where(w.join(' and '), "%#{params[:query].downcase}%").limit(5).order('name asc')
    respond_to do |format|
      format.json { render json: @products }  
    end     
  end

  def additions
    begin
      @product = Product.find(params[:product_id])
      @additions = @product.addition(active: true).children.order('name asc')
      raise ActiveRecord::RecordNotFound if @additions.blank?
    rescue 
      respond_to  do |format|
        format.html { render text: 'The product has no additives.', layout: false and return }
      end     
    end
    respond_to  do |format|
      format.html { render partial: 'additions', layout: false }
      format.json { render json: @additions }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.where(id: params[:id].to_i, organization_id: current_organization.id).take!
  end

  def product_params    
    params.require(:product).permit(:category_id, :name, :calories, :weight, :description, :active, :locked_to, :price, :addition_id, :avatar).merge(organization_id: current_organization.id)
  end
end
