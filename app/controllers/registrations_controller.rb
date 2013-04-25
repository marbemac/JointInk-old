class RegistrationsController < Devise::RegistrationsController
  layout 'fullscreen_bg'

  def new
    @fullscreen = true
    resource = build_resource({})
    respond_with resource
  end

  def create
    @fullscreen = true
    build_resource

    if resource.save
      if resource.active_for_authentication?
        Analytics.identify(user_id: resource.id, traits: resource.analytics_data)
        Analytics.track(user_id: resource.id, event: "Sign Up")
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
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

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path :show => 'confirm'
  end

end
