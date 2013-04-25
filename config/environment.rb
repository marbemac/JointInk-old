# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ThisThat::Application.initialize!

# For Passenger, because Analytics.init spawns a different thread, which is not properly copied and run between separate processes.
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|

    if forked # We're in smart spawning mode.
      Analytics.init(secret: 'q7wnl3ypkd6cz9i7x6c1')
    else
      # We're in direct spawning mode. We don't need to do anything.
    end
  end
end