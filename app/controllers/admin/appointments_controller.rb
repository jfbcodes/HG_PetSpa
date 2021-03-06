class Admin::AppointmentsController < Admin::BaseController
  helper :hot_glue
  include HotGlue::ControllerHelper

  
  
  before_action :load_appointment, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol ==  :turbo_stream }
 
  def load_appointment
    @appointment = (Appointment.find(params[:id]))
  end
  

  def load_all_appointments 
    @appointments = ( Appointment.page(params[:page]).includes(:pet))  
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


    @appointment = Appointment.create(modified_params)

    if @appointment.save
      flash[:notice] = "Successfully created #{@appointment.name}"
      load_all_appointments
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_appointments_path }
      end
    else
      flash[:alert] = "Oops, your appointment could not be created."
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

    if @appointment.update(modify_date_inputs_on_params(appointment_params))
      flash[:notice] = (flash[:notice] || "") << "Saved #{@appointment.name}"
    else
      flash[:alert] = (flash[:alert] || "") << "Appointment could not be saved."

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
      flash[:alert] = "Appointment could not be deleted"
    end
    load_all_appointments
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_appointments_path }
    end
  end

  def appointment_params
    params.require(:appointment).permit( [:when_at, :pet_id] )
  end

  def default_colspan
    2
  end

  def namespace
    "admin/" 
  end
end


