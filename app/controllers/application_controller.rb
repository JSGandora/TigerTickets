class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def user_is_logged_in?
    !!session[:cas_user]
  end

end
