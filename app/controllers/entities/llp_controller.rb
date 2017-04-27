class Entities::LlpController < ApplicationController
  
  before_action :current_page
  before_action :check_xhr_page
  before_action :set_entity, only: [:basic_info]
  before_action :add_breadcrum
  
  def basic_info
    #key = params[:entity_key]
    if request.get?
      #@entity = Entity.find_by(key: key)
      entity_check() if @entity.present?
      @entity       ||= Entity.new(type_: params[:type])
      @just_created = params[:just_created].to_b
    elsif request.post?
      @entity                 = Entity.new(entity_params)
      @entity.type_           = MemberType.getLLPId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id
      
      if @entity.save
        AccessResource.add_access({ user: current_user, resource: @entity })
        return render json: {redirect: view_context.entities_llp_basic_info_path( @entity.key ), just_created: true}
        #return redirect_to clients_path
      end
    elsif request.patch?
      #@entity                 = Entity.find_by(key: key)
      @entity.type_           = MemberType.getLLPId
      @entity.basic_info_only = true
      if @entity.update(entity_params)
        #return redirect_to edit_entity_path(@entity.key)
      end
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end
  
  def contact_info
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    if request.get?
      #TODO
    elsif request.patch?
      @entity.basic_info_only = false
      @entity.update(entity_params)
      return render layout: false, template: "entities/llp/contact_info"
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end
  
  def partner
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @partner                 = Partner.find(id) if id.present?
      @partner                 ||= Partner.new
      @partner.super_entity_id = @entity.id
    end
    if request.post?
      @partner                 = Partner.new(partner_params)
      @partner.super_entity_id = @entity.id
      @partner.class_name      = "Partner"
      if @partner.save
        @partners = @partner.super_entity.partners
        return render layout: false, template: "entities/llp/partners"
      else
        return render layout: false, template: "entities/llp/partner"
      end
    elsif request.patch?
      if @partner.update(partner_params)
        @partners = @partner.super_entity.partners
        return render layout: false, template: "entities/llp/partners"
      else
        return render layout: false, template: "entities/llp/partner"
      end
    elsif request.delete?
      partner = Partner.find(params[:id])
      @entity = partner.super_entity
      partner.delete
      @partners = partner.super_entity.partners
      return render layout: false, template: "entities/llp/partners"
    end
    render layout: false if request.xhr?
  end
  
  def partners
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @partners = @entity.partners
    render layout: false if request.xhr?
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  private
  def entity_params
    params.require(:entity).permit(:name, :address, :type_, :jurisdiction, :number_of_assets,
                                   :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                   :postal_address, :city, :state, :zip, :date_of_formation, 
                                   :ein_or_ssn, :s_corp_status, :not_for_profit_status, 
                                   :legal_ending, :honorific, :is_honorific, :has_comma)
  end
  
  def partner_params
    params.require(:partner).permit(:is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                    :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                    :my_percentage, :notes, :honorific, :is_honorific, :tax_member,
                                    :legal_ending, :has_comma)
  end
  
  def current_page
    @current_page = "entity"
  end
  
  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_llp_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end
  
  def set_entity
    key = params[:entity_key]
    @entity = Entity.find_by(key: key)
  end
  
  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    if params[:entity_key] and @entity.present? and !@entity.new_record?
      add_breadcrumb ("<div class=\"pull-left\"><h4><a href=\"#{edit_entity_path(@entity.key)}\">Edit LLP: <span id='edit-title-llp'>#{@entity.display_name}</span></a><span id='int-action-llp'></span></h4></div>").html_safe
    else
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } LLP </a></h4></div>".html_safe
    end    
    
    if params[:action] != "basic_info"
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe
    end
  end


end
