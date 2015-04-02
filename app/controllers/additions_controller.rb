class AdditionsController < ApplicationController
  before_action :authenticate_organization!
  before_action :is_ajax?
  before_action :set_addition, only: [:show, :edit, :update, :destroy]
  
  def show
    respond_to do |format|
      format.json { render json: @addition, status: :ok }
    end
  end

  def new
    @addition = current_organization.additions.new
    respond_to do |format|
      format.html { render 'form', layout: false }
    end
  end

  def edit
    respond_to do |format|
      format.html { render 'form', layout: false }
    end    
  end

  def index
    respond_to do |format|
      format.html { render 'index', locals: { additions: load_additions }, layout: false }
    end    
  end

  def create
    @addition = current_organization.additions.new(addition_params)
    respond_to do |format|
      if @addition.save
        format.json { render json: @addition, status: :created }
      else
        format.json { render json: @addition.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @addition.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @addition.update(addition_params)
        format.json { render json: @addition, status: :accepted }
      else
        format.json { render json: @addition.errors, status: :unprocessable_entity }
      end
    end    
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_addition
    @addition = Addition.where(id: params[:id].to_i, organization_id: current_organization.id).take!
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def addition_params    
    params.require(:addition).permit(:addition_id, :name, :active, :price).merge(organization_id: current_organization.id)
  end

  def load_additions
    @organization = Organization.find(params[:id])   
    if available_control?
      return @organization.get_additions(:all)
    else
      return @organization.get_additions
    end
  end  
end
