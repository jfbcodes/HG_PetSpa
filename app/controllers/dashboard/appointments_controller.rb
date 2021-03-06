class Dashboard::AppointmentsController < Dashboard::BaseController
  helper :hot_glue
  include HotGlue::ControllerHelper

  before_action :authenticate_human!
  
  before_action :load_appointment, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol ==  :turbo_stream }
 
  def load_appointment
    @appointment = (current_human.appointments.find(params[:id]))
  end
  

  def load_all_appointments 
    @appointments = ( current_human.appointments.page(params[:page]).includes(:pet))  
  end

  def index
    load_all_appointments
    respond_to do |format|
       format.html
    end
  end

  def new
    
    @appointment = Appointment.new()

   
    respond_to do |format|
      format.html
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(appointment_params.dup)
    modified_params = hawk_params( {pet_id: [current_human, "pets"] }, modified_params) 

    @appointment = Appointment.create(modified_params)

    if @appointment.save
      flash[:notice] = "Successfully created #{@appointment.name}"
      load_all_appointments
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to dashboard_appointments_path }
      end
    else
      flash[:alert] = "Oops, your appointment could not be created. #{@hawk_alarm}"
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    modified_params = modify_date_inputs_on_params(appointment_params, current_human)
    modified_params = hawk_params( {pet_id: [current_human, "pets"] }, modified_params) 
      
    if @appointment.update(modified_params)
      flash[:notice] = (flash[:notice] || "") << "Saved #{@appointment.name}"
      flash[:alert] = @hawk_alarm  if !@hawk_alarm.empty?
    else
      flash[:alert] = (flash[:alert] || "") << "Appointment could not be saved. #{@hawk_alarm}"

    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def destroy
    begin
      @appointment.destroy
    rescue StandardError => e
      flash[:alert] = "Appointment could not be deleted."
    end
    load_all_appointments
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to dashboard_appointments_path }
    end
  end

  def appointment_params
    params.require(:appointment).permit( [:when_at, :pet_id] )
  end

  def namespace
    "dashboard/" 
  end
end


