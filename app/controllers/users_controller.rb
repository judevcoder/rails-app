class UsersController < ApplicationController

  before_filter :authenticate_user!

  def update
    attributes = build_update_attributes
    @user = User.find(params[:id])
    if params[:status]
      @user.update_attributes(default: params[:status])
    elsif attributes
      @user.update_attributes(attributes)
    elsif params[:just_email]
      @user.update_attributes(just_email: params[:just_email])
    elsif params[:have_alt]
      @user.update_attributes(have_alt: params[:have_alt])
    end
    render :json => {:success => true}
  end

  def my
    @user = current_user
    if request.post?
      @user.first_name = params[:first_name]
      @user.last_name = params[:last_name]
      @user.save
      sign_in @user.reload
    end
  end

  private

  def build_update_attributes
    attributes = nil
    if params[:just_email] || params[:have_alt]
      if params[:just_email] == 'true'
        attributes = {just_email: 'true', have_alt: 'false'}
      end
      if params[:have_alt] == 'true'
        attributes = {just_email: 'false', have_alt: 'true'}
      end
    end
    attributes
  end
end
