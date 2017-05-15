class HomeController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:index]

  def index
    if current_user
      redirect_to properties_path
    else
      redirect_to new_user_session_path
    end
  end

  def set_user_indexing
    current_user.update(user_indexing: params[:set_val] == 'true')
    render :json => { :success => true}
  end

  def test
    render layout: false
  end
end
