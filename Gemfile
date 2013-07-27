source 'https://rubygems.org'

ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.4'

gem 'bundler'
gem 'rails', '4.0.0'
gem 'activerecord-jdbcpostgresql-adapter', '1.3.0.beta2'

gem 'jquery-rails'
gem "slim-rails"
gem 'honeybadger' # Exception notification
gem 'devise' # Authentication
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'json' # json
gem "cancan"
gem 'koala' # facebook graph api support
gem 'twitter' # twitter api support
gem 'chronic' # Date/Time management

gem 'rack-contrib'
gem 'rack-pjax'

gem 'cloudinary'
gem "switch_user"
gem 'annotate'
gem 'friendly_id', github: 'FriendlyId/friendly_id', branch: 'rails4'

gem 'reverse_markdown'
gem 'carrierwave'
gem 'fog'

gem 'kaminari'
gem 'simple_form', '~> 3.0.0.rc'
gem 'sanitize'
gem 'pg_search'
gem 'pg_array_parser'
gem 'turbo-sprockets-rails3'

gem 'truncate_html'

gem 'newrelic_rpm'

gem 'bust_rails_etags'
gem 'capistrano'
gem 'rvm-capistrano'
gem 'foreman'

gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier'
gem 'bourbon'
gem 'zurb-foundation', '~> 4.3.1'
gem 'font-awesome-rails'
gem 'jquery-fileupload-rails'

gem "torquebox", "3.0.0.beta1"
gem 'torquebox-capistrano-support'

group :production, :staging do
  gem "rack-timeout"
  gem 'therubyrhino'
end

group :development do
  gem 'rack-mini-profiler'
  gem 'pry-rails'
  gem 'meta_request'
end