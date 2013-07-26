JointInk::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.app_url = 'http://lvh.me:3000'

  # ActionMailer Config
  # Setup for development - deliveries, errors raised
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => 'lvh.me:3000' }
  Rails.application.routes.default_url_options = config.action_mailer.default_url_options # because this is what Resque looks for
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.smtp_settings = {
      :domain => 'jointink.com',
      :address => 'smtp.mailgun.org',
      :port => 587,
      :authentication => :plain,
      :user_name => 'postmaster@jointink.com',
      :password => '4dk4on3znay0'
  }
end
