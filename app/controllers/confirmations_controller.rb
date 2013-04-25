class ConfirmationsController < Devise::RegistrationsController
  layout 'fullscreen_bg'

  # GET /resource/confirmation/new
  def new
    @fullscreen = true
    @body_class = 'cover-image'
    build_resource({})
  end

  # POST /resource/confirmation
  def create
    @fullscreen = true
    @body_class = 'cover-image'
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    @fullscreen = true
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      Analytics.identify(user_id: resource.id, traits: resource.analytics_data)
      Analytics.track(user_id: resource.id, event: "Confirmation")
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render 'confirmations/new' }
    end
  end

  protected

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    after_sign_in_path_for(resource)
  end

end
