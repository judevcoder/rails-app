class DynamicFieldsController < ApplicationController
  before_action :set_dynamic_field, only: [:show, :edit, :update, :destroy]

  # GET /dynamic_fields
  # GET /dynamic_fields.json
  def index
    @dynamic_fields = DynamicField.all
  end

  # GET /dynamic_fields/1
  # GET /dynamic_fields/1.json
  def show
  end

  # GET /dynamic_fields/new
  def new
    @dynamic_field = DynamicField.new
  end

  # GET /dynamic_fields/1/edit
  def edit
  end

  # POST /dynamic_fields
  # POST /dynamic_fields.json
  def create
    @dynamic_field = DynamicField.new(dynamic_field_params)

    respond_to do |format|
      if @dynamic_field.save
        format.html { redirect_to @dynamic_field, notice: 'Dynamic field was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dynamic_field }
      else
        format.html { render action: 'new' }
        format.json { render json: @dynamic_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dynamic_fields/1
  # PATCH/PUT /dynamic_fields/1.json
  def update
    respond_to do |format|
      if @dynamic_field.update(dynamic_field_params)
        format.html { redirect_to @dynamic_field, notice: 'Dynamic field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_fields/1
  # DELETE /dynamic_fields/1.json
  def destroy
    @dynamic_field.destroy
    respond_to do |format|
      format.html { redirect_to dynamic_fields_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_field
      @dynamic_field = DynamicField.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_field_params
      params.require(:dynamic_field).permit(:klass, :fields, :validation, :default_value)
    end
end
