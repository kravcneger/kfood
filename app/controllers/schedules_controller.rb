class SchedulesController < ApplicationController
  before_action :authenticate_organization!, except: [:index]
  before_action :is_ajax?
  before_action :set_schedule, only: [:update, :destroy]

  def index
    @organization = current_organization
    @timetable = @organization.timetable.get_table
    respond_to do |format|
      format.html { render '_index', locals: {organization: @organization}, layout: false  }
    end
  end

  def create
    @schedule = Schedule.new(schedule_params)
    respond_to do |format|
      if @schedule.save
        format.json  { render json: :ok }
      else
        format.html { render 'render_erros', status: 400, layout: false  }
      end   
    end    
  end

  def update
    respond_to do |format|
      if @schedule.update(schedule_params) 
        format.json  { render json: :ok }
      else
        format.html { render 'render_erros', status: 400, layout: false  }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html { render 'edit', layout: false }
    end   
  end
  
  def set_holiday
    current_organization.timetable.set_holiday(params[:day].to_i)
    respond_to do |format|
      format.json  { render json: :ok }
    end   
  end

  def set_around
    current_organization.timetable.set_around(params[:day].to_i)
    respond_to do |format|
      format.json  { render json: :ok }
    end   
  end

  def destroy
    @schedule.destroy
    respond_to do |format|
      format.json  { render json: :ok }
    end      
  end

  private  

  # Use callbacks to share common setup or constraints between actions.
  def set_schedule
    @schedule = Schedule.where(id: params[:id].to_i, organization_id: current_organization.id).take!
  end

  def schedule_params    
    params.require(:schedule).permit(:day, :first_time, :second_time).merge(organization_id: current_organization.id)
  end

end
