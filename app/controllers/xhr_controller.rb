class XhrController < ApplicationController

  include ApplicationHelper

  layout false

  def clients_options_html
    obj = (params[:id].present?) ? SuperEntity.find(params[:id]) : nil
    @html = options_html(params[:client_type], params[:is_person], obj, params[:cid])
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
