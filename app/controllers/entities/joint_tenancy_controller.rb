class Entities::JointTenancyController < ApplicationController
  
  before_action :current_page
  before_action :check_xhr_page
  before_action :add_breadcrum
  
  def basic_info
    key = params[:entity_key]
    if request.get?
      @entity = Entity.find_by(key: key)
      if @entity.present?
        entity_check()
        @entity = EntityJointTenancy.find_by(key: key)
      end
      @entity       ||= EntityJointTenancy.new(type_: params[:type])
      @just_created = params[:just_created].to_b
    elsif request.post?
      @entity                 = EntityJointTenancy.new(entity_joint_tenancy_params)
      @entity.type_           = MemberType.new.getJointTenancyId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id
      
      if @entity.save
        AccessResource.add_access({ user: current_user, resource: Entity.find(@entity.id) })
        return render json: { redirect: view_context.entities_joint_tenancy_basic_info_path(@entity.key), just_created: true }
      end
    elsif request.patch?
      @entity                 = EntityJointTenancy.find_by(key: key)
      @entity.type_           = MemberType.new.getJointTenancyId
      @entity.basic_info_only = true
      @entity.update(entity_joint_tenancy_params)
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end
  
  # tenants_in_common
  def joint_tenant
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @joint_tenant                 = JointTenant.find(id) if id.present?
      @joint_tenant                 ||= JointTenant.new
      @joint_tenant.super_entity_id = @entity.id
    end
    if request.post?
      @joint_tenant                 = JointTenant.new(joint_tenant_params)
      @joint_tenant.super_entity_id = @entity.id
      @joint_tenant.class_name      = "JointTenant"
      if @joint_tenant.save
        @joint_tenants = @joint_tenant.super_entity.joint_tenants
        return render layout: false, template: "entities/joint_tenancy/joint_tenants"
      else
        return render layout: false, template: "entities/joint_tenancy/joint_tenant"
      end
    elsif request.patch?
      if @joint_tenant.update(joint_tenant_params)
        @joint_tenants = @joint_tenant.super_entity.joint_tenants
        return render layout: false, template: "entities/joint_tenancy/joint_tenants"
      else
        return render layout: false, template: "entities/joint_tenancy/joint_tenant"
      end
    elsif request.delete?
      joint_tenant = JointTenant.find(params[:id])
      joint_tenant.delete
      @entity        = joint_tenant.super_entity
      @joint_tenants = @entity.joint_tenants
      return render layout: false, template: "entities/joint_tenancy/joint_tenants"
    end
    render layout: false if request.xhr?
  end
  
  def joint_tenants
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @joint_tenants = @entity.joint_tenants
    render layout: false if request.xhr?
  end
  
  
  # Never trust parameters from the scary internet, only allow the white list through.
  private
  def entity_joint_tenancy_params
    params.require(:entity_joint_tenancy).permit(:name, :name2, :address, :type_, :jurisdiction, :number_of_assets,
                                                 :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                                 :postal_address, :postal_address2, :city, :city2, :state, :state2, :zip, :zip2, :date_of_formation, :m_date_of_formation,
                                                 :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific,
                                                 :date_of_appointment, :m_date_of_appointment, :country, :date_of_commission, :m_date_of_commission, :index)
  end
  
  def joint_tenant_params
    params.require(:joint_tenant).permit(:name, :name2, :address, :type_, :jurisdiction, :number_of_assets,
                                         :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                         :postal_address, :postal_address2, :city, :city2, :state, :state2, :zip, :zip2, :date_of_formation, :m_date_of_formation,
                                         :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific,
                                         :date_of_appointment, :m_date_of_appointment, :country, :date_of_commission, :m_date_of_commission, :index, :country2, :part, :my_percentage)
  end
  
  def current_page
    @current_page = "entity"
  end
  
  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_joint_tenancy_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end
  
  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Joint Tenancy </a></h4></div>".html_safe
  end
end
