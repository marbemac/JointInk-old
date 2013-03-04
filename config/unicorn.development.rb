worker_processes 3
timeout 30
preload_app true
listen 3001, :tcp_nopush => false

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end