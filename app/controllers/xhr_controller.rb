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
    #@types = MemberType.objects
    #MemberType.InitMemberTypes if @types.nil?
    @types = MemberType.objects
  end

  def entity_groups
    @groups = [{id: '0', parent: '#', text: 'All'}]
    groups = Group.where(gtype: 'Entity')
    groups.each do |grp|
      obj = {id: grp.id.to_s, parent: grp.parent_id.to_s, text: grp.name}
      @groups << obj
    end
    render :json => @groups.to_json 
  end

  def entity_child_groups
    @groups = []
    groups = Group.where(gtype: 'Entity', parent_id: params[:id])
    groups.each do |grp|
      obj = {id: grp.id.to_s, parent: '0', text: grp.name}
      @groups << obj
    end
    render :json => @groups.to_json  
  end

  def owns_list
    if request.xhr?
      @entity = Entity.where(id: params[:id]).first
      if !@entity.nil?
        result = owns(@entity)
        retArr = []
        result.each do |record|
          obj = {id: record[3]}
        end
      end 
    end
  end

end
