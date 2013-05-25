# Be sure to restart your server when you modify this file.

if Rails.env == 'production'
  JointInk::Application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 30.minutes
else
  JointInk::Application.config.session_store :cookie_store, key: '_JointInk_session', :domain => :all
end


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# JointInk::Application.config.session_store :active_record_store
