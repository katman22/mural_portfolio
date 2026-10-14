class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_admin

  private

  def authenticate_admin
    response.headers["Cache-Control"] = "no-store"
    return if User.exists?(id: session[:user_id], active: true)

    reset_session
    redirect_to admin_login_path
  end
end
