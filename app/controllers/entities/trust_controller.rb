class Entities::TrustController < ApplicationController

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
      @entity.type_           = MemberType.getTrustId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id

      if @entity.save
        AccessResource.add_access({ user: current_user, resource: @entity })
        return render json: {redirect: view_context.entities_trust_basic_info_path( @entity.key ), just_created: true}
        #return redirect_to clients_path
      end
    elsif request.patch?
      #@entity                 = Entity.find_by(key: key)
      @entity.type_           = MemberType.getTrustId
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
      return render layout: false, template: "entities/trust/contact_info"
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end

  def settlor
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @settlor                 = Settlor.find(id) if id.present?
      @settlor                 ||= Settlor.new
      @settlor.super_entity_id = @entity.id
    end
    if request.post?
      @settlor                 = Settlor.new(settlor_params)
      @settlor.use_temp_id
      @settlor.super_entity_id = @entity.id
      @settlor.class_name      = "Settlor"
      if @settlor.save
        @settlors = @settlor.super_entity.settlors
        return render layout: false, template: "entities/trust/settlors"
      else
        return render layout: false, template: "entities/trust/settlor"
      end
    elsif request.patch?
      if @settlor.update(settlor_params)
        @settlor.use_temp_id
        @settlors = @settlor.super_entity.settlors
        return render layout: false, template: "entities/trust/settlors"
      else
        return render layout: false, template: "entities/trust/settlor"
      end
    elsif request.delete?
      settlor = Settlor.find(params[:id])
      @entity = settlor.super_entity
      settlor.delete
      @settlors = settlor.super_entity.settlors
      return render layout: false, template: "entities/trust/settlors"
    end
    @settlor.gen_temp_id
    render layout: false if request.xhr?
  end

  def settlors
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @settlors = @entity.settlors
    render layout: false if request.xhr?
  end

  def trustee
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @trustee                 = Trustee.find(id) if id.present?
      @trustee                 ||= Trustee.new
      @trustee.super_entity_id = @entity.id
      @trustee.class_name      = "Trustee"
    end
    if request.post?
      @trustee                 = Trustee.new(trustee_params)
      @trustee.use_temp_id
      @trustee.super_entity_id = @entity.id
      if @trustee.save
        @trustees = @trustee.super_entity.trustees
        return render layout: false, template: "entities/trust/trustees"
      else
        return render layout: false, template: "entities/trust/trustee"
      end
    elsif request.patch?
      if @trustee.update(trustee_params)
        @trustees = @trustee.super_entity.trustees
        @trustee.use_temp_id
        return render layout: false, template: "entities/trust/trustees"
      else
        return render layout: false, template: "entities/trust/trustee"
      end
    elsif request.delete?
      trustee = Trustee.find(params[:id])
      @entity = trustee.super_entity
      trustee.delete
      @trustees = trustee.super_entity.trustees
      return render layout: false, template: "entities/trust/trustees"
    end
    @trustee.gen_temp_id
    render layout: false if request.xhr?
  end

  def trustees
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @trustees = @entity.trustees
    render layout: false if request.xhr?
  end

  def beneficiary
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @beneficiary                 = Beneficiary.find(id) if id.present?
      @beneficiary                 ||= Beneficiary.new
      @beneficiary.super_entity_id = @entity.id
      @beneficiary.class_name      = "Beneficiary"
    end
    if request.post?
      @beneficiary                 = Beneficiary.new(beneficiary_params)
      @beneficiary.use_temp_id
      @beneficiary.super_entity_id = @entity.id
      if @beneficiary.save
        @beneficiaries = @beneficiary.super_entity.beneficiaries
        return render layout: false, template: "entities/trust/beneficiaries"
      else
        return render layout: false, template: "entities/trust/beneficiary"
      end
    elsif request.patch?
      if @beneficiary.update(beneficiary_params)
        @beneficiary.use_temp_id
        @beneficiaries = @beneficiary.super_entity.beneficiaries
        return render layout: false, template: "entities/trust/beneficiaries"
      else
        return render layout: false, template: "entities/trust/beneficiary"
      end
    elsif request.delete?
      beneficiary = Beneficiary.find(params[:id])
      @entity     = beneficiary.super_entity
      beneficiary.delete
      @beneficiaries = beneficiary.super_entity.beneficiaries
      return render layout: false, template: "entities/trust/beneficiaries"
    end
    @beneficiary.gen_temp_id
    render layout: false if request.xhr?
  end

  def beneficiaries
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @beneficiaries = @entity.beneficiaries
    render layout: false if request.xhr?
  end

  def owns
    @entity = Entity.find_by(key: params[:entity_key])
    @ownership_ = @entity.build_ownership_tree_json
    @owns_available = (@ownership_[0][:nodes] == nil) ? false : true
    @ownership = @ownership_.to_json
    raise ActiveRecord::RecordNotFound if @entity.blank?
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

  def settlor_params
    params.require(:settlor).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                    :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                    :stock_share, :notes, :honorific, :is_honorific, :my_percentage, :tax_member, :contact_id)
  end

  def beneficiary_params
    params.require(:beneficiary).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                        :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                        :stock_share, :notes, :honorific, :is_honorific, :my_percentage, :tax_member, :contact_id)
  end

  def trustee_params
    params.require(:trustee).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                    :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                    :stock_share, :notes, :honorific, :is_honorific, :my_percentage, :tax_member, :contact_id)
  end

  def current_page
    @current_page = "entity"
  end

  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_trust_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
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
      add_breadcrumb ("<div class=\"pull-left\"><h4><a href=\"#{edit_entity_path(@entity.key)}\">Edit Trust: <span id='edit-title-trust'>#{@entity.name}</span></a><span id='int-action-trust'></span></h4></div>").html_safe
    else
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action] == "basic_info" ? "Add" : "" } Trust </a></h4></div>".html_safe
    end

    if params[:action] != "basic_info"
      add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/clients\">#{params[:action].titleize}</a></h4></div>".html_safe
    end
  end

end
