source :rubygems

ruby '2.0.0'

gem 'bundler'
gem 'rails', '~> 3.2.13'

gem 'jquery-rails'
gem "slim-rails"
gem 'pg'
gem 'honeybadger' # Exception notification
gem 'devise' # Authentication
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'yajl-ruby' # json
gem "sendgrid"
gem "cancan", ">= 1.6.8"
gem 'koala', '1.6' # facebook graph api support
gem 'twitter' # twitter api support
gem 'chronic' # Date/Time management

gem 'dalli' # memcache

gem 'rack-contrib', '1.1.0'
gem 'rack-pjax'

gem 'mixpanel' # analytics
gem 'cloudinary'
gem "switch_user"
gem 'annotate'
gem 'activerecord-postgres-hstore'
gem 'ar_pg_array'
gem "friendly_id", "~> 4.0.9"

gem 'redcarpet'
gem 'carrierwave'
gem 'fog'

gem 'kaminari'
gem 'cache_digests'
gem 'simple_form'
gem 'sanitize'
gem 'pg_search'

gem 'truncate_html'

gem 'newrelic_rpm'

gem 'capistrano'
gem 'foreman'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'zurb-foundation'
  gem 'font-awesome-rails'
  gem 'jquery-fileupload-rails'
end

group :production, :staging do
  gem "rack-timeout"
end

group :development do
  gem 'rack-mini-profiler'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'rails-dev-tweaks'
end