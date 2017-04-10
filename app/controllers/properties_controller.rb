class PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :edit, :destroy]
  before_action :current_page
  before_action :add_breadcrum
  # GET /properties
  # GET /properties.json
  def index
    @properties = Property.with_deleted.where(id: AccessResource.get_ids(resource_klass: 'Property', user: current_user))
    @properties = @properties.where(deleted_at: nil) unless params[:trashed].to_b
    @properties = @properties.where.not(deleted_at: nil) if params[:trashed].to_b
    @properties = @properties.order(created_at: :desc).paginate(page: params[:page], per_page: sessioned_per_page)
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"#\"> List </a></h4></div>".html_safe
    
    render template: 'properties/xhr_list', layout: false if request.xhr?
  end
  
  # GET /properties/1
  # GET /properties/1.json
  def show
    @procedures = @property.procedures
  end
  
  # GET /properties/new
  def new
    @property = Property.new
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties/new\"> Basic Info </a></h4></div>".html_safe
    render layout: false if request.xhr?
  end
  
  # GET /properties/1/edit
  def edit
  end
  
  # POST /properties
  # POST /properties.json
  def create
    @property         = Property.new(property_params)
    @property.user_id = current_user.id
    respond_to do |format|
      if @property.save
        AccessResource.add_access({ user: current_user, resource: @property })
        format.html { redirect_to properties_path }
        format.js { render json: @property.to_json, status: :ok }
        format.json { render action: 'show', status: :created, location: @property }
      else
        format.html { render action: 'new' }
        format.js { render action: 'new', status: :unprocessable_entity, layout: false }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    @property = Property.find(params[:id])
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to edit_property_path(@property.key, type_is: params[:type_is]) }
        format.json { render action: 'show', status: :created, location: @property }
      else
        format.html { render action: 'new' }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
  
  def member
    @action = Procedure::Action.find_by(key: params[:id])
    if request.post?
      email = params[:email]
      if email.email?
        user = User.find_by(email: email)
        user ||= Users::Unregistered.find_or_create_by(email: email)
        if user.class.to_s == 'User'
          access_resource = AccessResource.find_or_create_by(resource_id: @action.id, resource_klass: @action.class.to_s, user_id: user.id)
        else
          access_resource = AccessResource.find_or_create_by(resource_id: @action.id, resource_klass: @action.class.to_s, unregistered_u_k: user.key)
        end
        access_resource.permission_type = params[:permission_type]
        access_resource.can_access      = (user.class.to_s == 'User')
        access_resource.save
        ######### Send Email Notification #########
        options                         = {}
        options[:user]                  = user
        options[:work_group]            = @action.title
        options[:owner_name_with_email] = "<#{current_user.email}>"
        options[:permission_type]       = access_resource.permission_type_
        options[:work_group_id]         = @action.key
        # UserMailer.work_group_access_notify_with_signup(options).deliver
        ######### Send Email Notification #########
      else
        flash[:notice] = 'Invalid Email'
      end
    end
    render layout: false
  end
  
  def multi_delete
    common_multi_delete
  end
  
  def xhr_list_dropdown
    @property = Property.find_by(id: params[:id])
    if params[:person] == "true"
      @klass = "Person"
      @entities =  @property.ownership_person_dropdown
    else
      @entities =  @property.ownership_entity_dropdown
    end

    render layout: false
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_property
    @property = Property.find_by(key: params[:id])
    raise ActiveRecord::RecordNotFound if @property.blank?
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def property_params
    params.require(:property).permit!
  end
  
  def current_page
    @current_page = 'property'
  end
  
  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties\">Properties </a></h4></div>".html_safe
    if params[:action] == "edit"
      if params[:type_is] == 'county_tax'
        add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties\"> County Tax </a></h4></div>".html_safe
      elsif params[:type_is] == 'tenant'
        add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties\"> Tenant </a></h4></div>".html_safe
      elsif params[:type_is] == 'lease'
        add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties\"> Lease </a></h4></div>".html_safe
      elsif params[:type_is] == 'ownership'
        add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties\"> Ownership </a></h4></div>".html_safe
      else
        add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/properties\"> Basic Info </a></h4></div>".html_safe
      end
    end
  
  end
end
