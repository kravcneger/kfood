class ApplicationController < ActionController::Base
	include Access
	include Ajax
  include UrlHelper
#	before_filter :configure_permitted_parameters, if: :devise_controller?
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception 
  
  def after_sign_in_path_for(resource)
  	flash.clear
  	organization_path(current_organization)
  end 

  def after_sign_out_path_for(resource_or_scope)
    blacklist = [new_organization_session_path] 
    last_url = request.referrer
    if blacklist.include?(last_url)
      root_path
    else
      last_url
    end    
  end

end
