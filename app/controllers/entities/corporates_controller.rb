class Entities::CorporatesController < ApplicationController

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
      @entity.type_           = MemberType.getCorporationId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id
      if @entity.save
        AccessResource.add_access({ user: current_user, resource: @entity })
        return render json: { redirect: view_context.entities_corporates_basic_info_path(@entity.key), just_created: true }
      end
    elsif request.patch?
      #@entity                 = Entity.find_by(key: key)
      @entity.type_           = MemberType.getCorporationId
      @entity.basic_info_only = true
      @entity.update(entity_params)
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
      return render layout: false, template: "entities/corporates/contact_info"
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end

  def director
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"#\">Director </a></h4></div>".html_safe
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @director = Director.find(id) if id.present?
      @director ||= Director.new
    end
    if request.post?
      @director                 = Director.new(director_params)
      @director.super_entity_id = @entity.id
      @director.class_name      = "Director"
      if @director.save
        @directors = @director.super_entity.directors
        return render layout: false, template: "entities/corporates/directors"
      else
        return render layout: false, template: "entities/corporates/director"
      end
    elsif request.patch?
      if @director.update(director_params)
        @directors = @director.super_entity.directors
        return render layout: false, template: "entities/corporates/directors"
      else
        return render layout: false, template: "entities/corporates/director"
      end
    elsif request.delete?
      director = Director.find(params[:id])
      @entity  = director.super_entity
      director.delete
      @directors = director.super_entity.directors
      return render layout: false, template: "entities/corporates/directors"
    end
    render layout: false if request.xhr?
  end

  def directors
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"#\">Directors </a></h4></div>".html_safe
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @directors = @entity.directors
    render layout: false if request.xhr?
  end

  def officer
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"#\">Officer </a></h4></div>".html_safe
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @officer = Officer.find(id) if id.present?
      @officer ||= Officer.new
    end
    if request.post?
      @officer           = Officer.new(officer_params)
      @officer.entity_id = @entity.id
      if @officer.save
        @officers = @officer.entity.officers
        return render layout: false, template: "entities/corporates/officers"
      else
        return render layout: false, template: "entities/corporates/officer"
      end
    elsif request.patch?
      if @officer.update(officer_params)
        @officers = @officer.entity.officers
        return render layout: false, template: "entities/corporates/officers"
      else
        return render layout: false, template: "entities/corporates/officer"
      end
    elsif request.delete?
      officer = Officer.find(params[:id])
      @entity = officer.entity
      officer.delete
      @officers = officer.entity.officers
      return render layout: false, template: "entities/corporates/officers"
    end
    render layout: false if request.xhr?
  end

  def officers
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"#\">Officers </a></h4></div>".html_safe
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @officers = @entity.officers
    render layout: false if request.xhr?
  end

  def stockholder
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"#\">Officers </a></h4></div>".html_safe
    p "in stockholder"
    p params
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      p "entity"
      p @entity
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @stockholder                 = StockHolder.find(id) if id.present?
      @stockholder                 ||= StockHolder.new      
      @stockholder.super_entity_id = @entity.id
      @stockholder.class_name      = "StockHolder"
    end
    if request.post?
      @stockholder                 = StockHolder.new(stockholder_params)
      @stockholder.use_temp_id
      @stockholder.super_entity_id = @entity.id
      @stockholder.class_name      = "StockHolder"
      if @stockholder.save
        @stockholders = @entity.stockholders
        return render layout: false, template: "entities/corporates/stockholders"
      else
        return render layout: false, template: "entities/corporates/stockholder"
      end
    elsif request.patch?
      @stockholder.assign_attributes(stockholder_params)
      @stockholder.use_temp_id      
      if @stockholder.save
        @stockholders = @entity.stockholders
        return render layout: false, template: "entities/corporates/stockholders"
      else
        return render layout: false, template: "entities/corporates/stockholder"
      end
    elsif request.delete?
      stockholder = StockHolder.find(params[:id])
      stockholder.delete
      @entity = Entity.find_by(key: stockholder.super_entity.key)
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @stockholders = @entity.stockholders
      return render layout: false, template: "entities/corporates/stockholders"
    
      
    end
    p "before gen temp"
    p @stockholder
    @stockholder.gen_temp_id
    p "after fen temp"
    p @stockholder
    render layout: false if request.xhr?
  end

  def stockholders(entity_key = params[:entity_key])
    @entity = Entity.find_by(key: entity_key)
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @stockholders = @entity.stockholders
    render layout: false if request.xhr?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private
  def entity_params
    params.require(:entity).permit(:name, :address, :type_, :jurisdiction, :number_of_assets,
                                   :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                   :postal_address, :city, :state, :zip, :date_of_formation, :m_date_of_formation,
                                   :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific)
  end

  def set_entity
    key = params[:entity_key]
    @entity = Entity.find_by(key: key)
  end

  def stockholder_params
    params.require(:stock_holder).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2, :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn, :my_percentage, :notes, :honorific, :is_honorific, :contact_id)
  end

  def officer_params
    params.require(:officer).permit(:office, :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                    :postal_address, :city, :state, :zip, :notes, :honorific, :is_honorific, :person_type)
  end

  def director_params
    params.require(:director).permit(:first_name, :last_name, :phone1, :phone2,
                                     :fax, :email, :postal_address, :city, :state, :zip, :honorific, :is_honorific)
  end

  def current_page
    @current_page = "entity"
  end

  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_corporates_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end

  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">Clients </a></h4></div>".html_safe
    if params[:entity_key] and @entity.present? and !@entity.new_record?
      add_breadcrumb ("<div class=\"pull-left\"><h4><a href=\"#{edit_entity_path(@entity.key)}\">Edit Corporation: #{@entity.name}</a></h4></div>").html_safe
    else
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Corporation </a></h4></div>".html_safe
    end

    if params[:action] != "basic_info"
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe
    end
  end


end


class UnknownRequestFormat < Exception;
end
