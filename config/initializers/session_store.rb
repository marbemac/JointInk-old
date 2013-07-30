# Configure the TorqueBox Servlet-based session store.
# Provides for server-based, in-memory, cluster-compatible sessions

if ENV['TORQUEBOX_APP_NAME']
  JointInk::Application.config.session_store :torquebox_store, :key => '_JointInk_session'
else
  JointInk::Application.config.session_store :cookie_store, :key => '_JointInk_session', :domain => :all
end