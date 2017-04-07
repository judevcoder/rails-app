class HomeController < ApplicationController

  def index
    redirect_to properties_path
  end

  def set_user_indexing
    current_user.update(user_indexing: params[:set_val] == 'true')
    render :json => { :success => true}
  end

  def test
    render layout: false
  end
end
