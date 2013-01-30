source :rubygems

ruby '1.9.3'

gem 'bundler', '~> 1.2'
gem 'rails', '~> 3.2.11'

gem 'jquery-rails'
gem "haml-rails"
gem 'pg'
gem 'honeybadger' # Exception notification
gem 'devise' # Authentication
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'yajl-ruby' # json
gem "sendgrid"
gem "cancan", ">= 1.6.8"
gem 'rack-contrib', '1.1.0'
gem 'koala', '1.6' # facebook graph api support
gem 'twitter' # twitter api support
gem 'chronic' # Date/Time management

gem 'memcachier' # modify ENV variables to make dalli work with memcachier
gem 'dalli', '2.6.0' # memcache

gem 'rack-pjax'

gem 'mixpanel' # analytics
gem 'cloudinary'
gem "switch_user"
gem 'annotate'
gem 'activerecord-postgres-hstore'
gem 'ar_pg_array'
#gem 'activerecord-postgres-array'
gem "friendly_id", "~> 4.0.9"

gem 'carrierwave'
gem 'fog'

gem 'kaminari'
gem 'sidekiq' # background jobs
gem 'sinatra' # for sidekiq
gem 'slim' # for sidekiq
gem 'cache_digests'
gem 'hirefire-resource'
gem 'simple_form'
gem 'sanitize'
gem 'pg_search'
#gem 'turbo-sprockets-rails3' # speed up asset compiling

gem 'newrelic_rpm', '~> 3.5.4'

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
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test do
  gem "rspec-rails", ">= 2.12.2"
  gem "capybara", ">= 1.1.2"
  gem "email_spec", ">= 1.2.1"
  gem "launchy", ">= 2.1.2"
  gem "factory_girl_rails", ">= 4.0.0"
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'database_cleaner'
end