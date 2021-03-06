class LocalDevise::ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      if resource.user_exists_but_force_password_reset?
        token = resetting_password
        respond_with_navigational(resource) { redirect_to after_confirmation_set_password_path_for(token) }
      else
        # since update_attribute picks this up as a 'dirty' attribute
        resource.confirmation_token = nil

        # force manual update by admin
        # resource.update_attribute(:role, 'user') if resource.role?('guest')

        set_flash_message(:notice, :confirmed) if is_navigational_format?
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  private

  def resetting_password(resource)
    # TODO: is security issue created by connecting password creation to email confirmation?
    set_flash_message(:notice, :confirmed_need_password) if is_navigational_format?
    set_reset_password_token(resource)
  end

  def set_reset_password_token(resource)
    raw, enc = Devise.token_generator.generate(resource.class, :reset_password_token)
    resource.reset_password_token   = enc
    resource.reset_password_sent_at = Time.now.utc
    resource.save!(validate: false)
    raw
  end

  def after_confirmation_path_for(resource_name, resource)
    DeviseUsageLog.log(resource, DeviseAction::Confirmed)
    new_session_path(resource_name)
  end

  def after_confirmation_set_password_path_for(token)
    DeviseUsageLog.log(resource, DeviseAction::Confirmed)
    edit_user_password_path(reset_password_token: token)
  end

end
