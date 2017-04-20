class XhrController < ApplicationController

  include ApplicationHelper

  layout false

  def clients_options_html
    obj = SuperEntity.find(params[:id])
    @html = options_html('stockholder', params[:is_person], obj)
  end

  def client_entity
    val          = params[:val]
    @stockholder = params[:stockholder].to_b
    @entities    = Entity.where("name LIKE ?", "%#{val}%")
  end

  def entity_type_list
    @types = MemberType.objects
    MemberType.InitMemberTypes if @types.nil?
    @types = MemberType.objects
  end

end
