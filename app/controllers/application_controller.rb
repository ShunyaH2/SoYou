class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    resource.is_a?(AdminUser) ? admin_root_path : root_path
  end

  def after_sign_out_path_for(scope)
    scope == :admin ? new_admin_session_path : new_user_session_path
  end
end