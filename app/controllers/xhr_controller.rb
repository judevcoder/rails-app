class XhrController < ApplicationController

  include ApplicationHelper

  layout false


  def client_entity
    val          = params[:val]
    @stockholder = params[:stockholder].to_b
    @entities    = Entity.where("name LIKE ?", "%#{val}%")
  end

  def entity_type_list
    @types = MemberType.objects
  end

end
