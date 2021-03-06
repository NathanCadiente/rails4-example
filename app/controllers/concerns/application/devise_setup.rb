module Application::DeviseSetup

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user|
      user.permit(:username, :email, :role, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.permit(:sign_in) do |user|
      user.permit(:username, :password, :remember_me)
    end
    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit(:username, :email, :role, :current_password, :password, :password_confirmation)
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource_or_scope)
    DeviseUsageLog.log(resource_or_scope, DeviseAction::Login)
    stored_location_for(resource_or_scope) || signed_in_root_path(resource_or_scope)
  end
end
