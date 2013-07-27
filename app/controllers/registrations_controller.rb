class RegistrationsController < Devise::RegistrationsController
  layout 'splash_page'

  def new
    build_resource({})
    respond_with self.resource
  end

  def create
    build_resource(sign_up_params)

    if resource.save
      set_session_analytics("Sign Up")
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected

  def sign_up_params
    devise_parameter_sanitizer.for(:sign_up)
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path :show => 'confirm'
  end

end
