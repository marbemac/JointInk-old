worker_processes 3
timeout 30
preload_app true
port = ENV["PORT"].to_i
listen port, :tcp_nopush => false