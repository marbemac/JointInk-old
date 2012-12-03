class ApplicationController < ActionController::Base
  before_filter :init, :set_user_time_zone, :save_referer

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => (lambda do |exception|
      notify_airbrake(exception)
      logger.error"\n#{exception.class} (#{exception.message}):\n"
      render_error 500, exception
    end)
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, :with => (lambda do |exception|
      notify_airbrake(exception)
      logger.error"\n#{exception.class} (#{exception.message}):\n"
      render_error 404, exception
    end)
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
    unless signed_in?
      unless session['referer']
        session['referer'] = request.referer || 'none'
      end
    end
  end

  # Mixpanel
  def track_mixpanel(name, params)
    #resque.enqueue(MixpanelTrackEvent, name, params, request.env.select{|k,v| v.is_a?(String) || v.is_a?(Numeric) })
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

  private

  def init
    @body_class = ''
    @fullscreen = false
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if signed_in? && current_user
    Chronic.time_class = Time.zone
  end

  # open graph tags
  def build_og_tags(title, type, url, image, desc, extra={})
    og_tags = []
    og_tags << ["og:title", title]
    og_tags << ["og:type", type]
    og_tags << ["og:url", url]
    og_tags << ["og:image", image] if image && !image.blank?
    og_tags << ["og:description", desc]
    extra.each do |k,e|
      og_tags << [k, e]
    end
    og_tags
  end

  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/error', status: status }
      format.all { render nothing: true, status: status }
    end
  end
end
