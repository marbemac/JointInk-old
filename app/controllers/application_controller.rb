class ApplicationController < ActionController::Base
  include UrlHelper
  before_action :catch_flash, :init, :set_user_time_zone, :save_referer
  before_action :configure_permitted_parameters, if: :devise_controller?

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => (lambda do |exception|
      notify_honeybadger(exception)
      logger.error"\n#{exception.class} (#{exception.message}):\n"
      render_error 500, exception
    end)
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, :with => (lambda do |exception|
      #notify_honeybadger(exception) # getting exceptions for 404s is kind of excessive
      logger.error"\n#{exception.class} (#{exception.message}):\n"
      render_error 404, exception
    end)
  end

  def current_ability
    current_user ? current_user.ability : Ability.new(nil)
  end

  # Redirect after sign in / sign up
  def after_sign_in_path_for(resource)
    back_or_default_path root_path
  end

  def back_or_default_path(default)
    path = session[:return_to] ? session[:return_to] : default
    session[:return_to] = nil
    path
  end

  def save_referer
    unless user_signed_in?
      unless session['referer']
        session['referer'] = request.referer || 'none'
      end
    end
  end

  def build_ajax_response(status, redirect=nil, flash=nil, errors=nil, extra=nil, object=nil)
    response = {:status => status, :event => "#{params[:controller]}_#{params[:action]}"}
    response[:redirect] = redirect if redirect
    response[:flash] = flash if flash
    response[:errors] = errors if errors
    response[:object] = object if object
    response.merge!(extra) if extra
    response
  end

  def not_found(message='Not Found')
    raise ActionController::RoutingError.new(message)
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password) }
  end

  def catch_flash
    if params[:notice] || params[:alert]
      flash[:notice] = params[:notice] if params[:notice]
      flash[:alert] = params[:alert] if params[:alert]
      redirect_to request.fullpath.split('?').first
    end
  end

  def init
    @body_class = ''
    @fullscreen = false
    @page_title = nil
    @og_tags = {
        "og:site_name" => 'Joint Ink',
        "og:site_title" => "Joint Ink",
        "og:type" => "website",
        "og:url" => request.url,
        "og:description" => "Joint Ink is a new type of publishing platform."
    }
    @page_entities = []
  end

  def set_user_time_zone
    if request.cookies["time_zone"]
      min = request.cookies["time_zone"].to_i
      Time.zone = ActiveSupport::TimeZone[-min.minutes]
      Chronic.time_class = Time.zone
    end
  end

  # open graph tags
  def build_og_tags(title, type, url, desc, extra={})
    @og_tags = {}
    @og_tags["og:title"] = title
    @og_tags["og:type"] = type
    @og_tags["og:url"] = url
    @og_tags["og:description"] = desc
    extra.each do |k,e|
      @og_tags[k] = e
    end
  end

  # for segment.io
  def analytics_context(user=nil)
    context = {
        userAgent: request.env['HTTP_USER_AGENT'],
        ip: request.remote_ip
    }
    if cookies[:_ga]
      context['Google Analytics'] = {
          :clientId => cookies[:_ga]
      }
    end
    if user
      context[:traits] = user.analytics_data
    end
    context
  end

  def add_page_entity(entity_name, entity)
    @page_entities << {'name' => entity_name, 'entity' => entity} if entity
  end

  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/error', status: status }
      format.all { render nothing: true, status: status }
    end
  end

  # Sets a temporary
  def set_session_analytics(event, properties={})
    session[:analytics] = {:event => event, :properties => properties}
  end
end
