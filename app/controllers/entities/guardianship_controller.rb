class Entities::GuardianshipController < ApplicationController
  
  before_action :current_page
  before_action :check_xhr_page
  before_action :set_entity, only: [:basic_info]
  before_action :add_breadcrum
  
  def basic_info
    #key = params[:entity_key]
    if request.get?
      #@entity = Entity.find_by(key: key)
      #if @entity.present?
      #  entity_check()
      #  @entity = EntityGuardianship.find_by(key: key)
      #end
      @entity       ||= EntityGuardianship.new(type_: params[:type])
      @just_created = params[:just_created].to_b
    elsif request.post?
      @entity                 = EntityGuardianship.new(entity_guardianship_params)
      @entity.type_           = MemberType.getGuardianshipId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id
      @entity.name = "In re " + @entity.first_name + " " + @entity.last_name + ", AIP"
      if @entity.save
        AccessResource.add_access({user: current_user, resource: Entity.find(@entity.id)})
        return render json: {redirect: view_context.entities_guardianship_basic_info_path( @entity.key ), just_created: true}
        #return redirect_to clients_path
      end
    elsif request.patch?
      #@entity                 = EntityGuardianship.find_by(key: key)
      @entity.type_           = MemberType.getGuardianshipId
      @entity.basic_info_only = true
      @entity.assign_attributes(entity_guardianship_params)
      @entity.name = "In re " + @entity.first_name + " " + @entity.last_name + ", AIP"
      if @entity.save
       #return redirect_to edit_entity_path(@entity.key)
      end
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end
  
  def judge
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    if request.get?
      #TODO
    elsif request.patch?
      @entity.basic_info_only = false
      @entity.update(entity_params)
      return render layout: false, template: "entities/guardianship/judge"
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  private
  def entity_guardianship_params
    params.require(:entity_guardianship).permit(:name, :name2, :address, :type_, :jurisdiction, :number_of_assets,
                                                :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                                :postal_address, :postal_address2, :city, :city2, :state, :state2, :zip, :zip2, :date_of_formation, :m_date_of_formation,
                                                :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific,
                                                :date_of_appointment, :m_date_of_appointment, :country, :date_of_commission, :m_date_of_commission, :index, :county, :judge_first_name, :judge_last_name, :guardian_first_name, :guardian_last_name)
  end
  
  def entity_params
    params.require(:entity).permit(:name, :name2, :address, :type_, :jurisdiction, :number_of_assets,
                                   :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                   :postal_address, :postal_address2, :city, :city2, :state, :state2, :zip, :zip2, :date_of_formation, :m_date_of_formation,
                                   :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific,
                                   :date_of_appointment, :m_date_of_appointment, :country, :date_of_commission, :m_date_of_commission, :index, :country2, :part, :county)
  end
  
  def current_page
    @current_page = "entity"
  end
  
  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_guardianship_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end

  def set_entity
    key = params[:entity_key]
    @entity = Entity.find_by(key: key)
    if @entity.present?
      entity_check()
      @entity = EntityGuardianship.find_by(key: key)
    end
  end
  
  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    if params[:entity_key] and @entity.present? and !@entity.new_record?
      add_breadcrumb ("<div class=\"pull-left\"><h4><a href=\"#{edit_entity_path(@entity.key)}\">Edit Guardianship: <span id='edit-title-g'>#{@entity.name}</span></a></h4></div>").html_safe
    else
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Guardianship </a></h4></div>".html_safe
    end    
    
    if params[:action] != "basic_info"
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe
    end
  end

end
