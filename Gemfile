source :rubygems

ruby '1.9.3'

gem 'bundler', '~> 1.2'
gem 'rails', '~> 3.2.9'

gem 'jquery-rails'
gem "haml-rails"
gem 'pg'
gem 'airbrake' # Exception notification
gem 'devise' # Authentication
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'yajl-ruby' # json
gem "sendgrid"
gem "cancan", ">= 1.6.8"
gem 'rack-contrib'
gem 'soulmate', '0.1.3', :require => 'soulmate/server' # Redis based autocomplete storage
gem 'koala', '1.5' # facebook graph api support
gem 'twitter' # twitter api support
gem 'chronic' # Date/Time management

gem 'memcachier' # modify ENV variables to make dalli work with memcachier
gem 'dalli' # memcache

gem 'rack-pjax'

gem 'pusher' # pusher publish/subscribe
gem 'mixpanel' # analytics
gem 'cloudinary'
gem "switch_user"
gem 'annotate'
gem 'activerecord-postgres-hstore'
#gem 'activerecord-postgres-array'
gem "friendly_id", "~> 4.0.1"
gem 'carrierwave'
gem 'kaminari'
gem 'sidekiq' # background jobs
gem 'sinatra' # for sidekiq
gem 'slim' # for sidekiq
gem 'cache_digests'
gem 'mechanize'
gem 'hirefire-resource', :git => 'git://github.com/meskyanichi/hirefire-resource.git'
gem 'heroku-api'
gem 'simple_form'
gem 'redcarpet'
gem 'sanitize'
#gem 'turbo-sprockets-rails3' # speed up asset compiling

gem 'newrelic_rpm', '~> 3.5.0'

gem 'rmagick'

group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'zurb-foundation'
  gem 'font-awesome-rails'
  gem 'jquery-fileupload-rails'
end

group :production, :staging do
  gem "rack-timeout"
  gem 'unicorn'
end

group :development do
  gem 'rack-mini-profiler'
  gem 'foreman'
  gem 'pry-rails'
  gem 'thin'
end

group :test do
  gem "rspec-rails", ">= 2.11.0"
  gem "capybara", ">= 1.1.2"
  gem "email_spec", ">= 1.2.1"
  gem "cucumber-rails", ">= 1.3.0", :require => false
  gem "launchy", ">= 2.1.2"
  gem "factory_girl_rails", ">= 4.0.0"
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'database_cleaner'
end