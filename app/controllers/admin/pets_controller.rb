class Admin::PetsController < Admin::BaseController
  helper :hot_glue
  include HotGlue::ControllerHelper

  
   
  before_action :human

    
  before_action :load_pet, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol ==  :turbo_stream }

  def human
      @human ||= Human.find(params[:human_id]) 
  end
  
    
  
     
  def load_pet
    @pet = (human.pets.find(params[:id]))
  end
  

  def load_all_pets 
    @pets = ( human.pets.page(params[:page]))  
  end

  def index
    load_all_pets
    respond_to do |format|
       format.html
    end
  end

  def new
    
    @pet = Pet.new(human: @human)
   
    respond_to do |format|
      format.html
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(pet_params.dup.merge!( human: @human) )


    @pet = Pet.create(modified_params)

    if @pet.save
      flash[:notice] = "Successfully created #{@pet.name}"
      load_all_pets
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_human_pets_path }
      end
    else
      flash[:alert] = "Oops, your pet could not be created."
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

    if @pet.update(modify_date_inputs_on_params(pet_params))
      flash[:notice] = (flash[:notice] || "") << "Saved #{@pet.name}"
    else
      flash[:alert] = (flash[:alert] || "") << "Pet could not be saved."

    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def destroy
    begin
      @pet.destroy
    rescue StandardError => e
      flash[:alert] = "Pet could not be deleted"
    end
    load_all_pets
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_human_pets_path }
    end
  end

  def pet_params
    params.require(:pet).permit( [:name] )
  end

  def default_colspan
    1
  end

  def namespace
    "admin/" 
  end
end


