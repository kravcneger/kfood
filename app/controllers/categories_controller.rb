class CategoriesController < ApplicationController
  before_action :authenticate_organization!
  before_action :is_ajax?
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  
  def show
    respond_to do |format|
      format.json { render json: @category, status: :ok }
    end
  end

  # GET /categories/new
  def new
    @category = current_organization.categories.new
    respond_to do |format|
      format.html { render 'form', layout: false }
    end
  end

  # GET /categories/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form', layout: false }
    end    
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = current_organization.categories.new(category_params)
    respond_to do |format|
      if @category.save
        format.json { render json: @category, status: :created }
      else
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.json { render json: @category, status: :accepted }
      else
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    if @category.children.present? 
      respond_to do |format|
        format.json { render json: I18n.t('category_have_sub_categories'), status: :conflict }
      end
    else
      @category.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  def load_menu
    @organization = current_organization
    respond_to do |format|
      format.html { render '_list', locals: { categories: current_organization.get_menu(:all) }, layout: false }
    end
  end

  def get_brothers
    @category = current_organization.categories.new(category_params)
    respond_to do |format|
      format.json { render json: @category.get_brothers , :only => [:id, :name] }
    end 
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.where(id: params[:id].to_i, organization_id: current_organization.id).take!
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def category_params    
    params.require(:category).permit(:category_id, :name, :active, :after_category).merge(organization_id: current_organization.id)
  end
end
