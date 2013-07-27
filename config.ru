# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run JointInk::Application


environment.context_class.class_eval do
  def asset_path(path, options = {})
    "/assets/#{path}"
  end
end