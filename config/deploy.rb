require 'bundler/capistrano'
require "rvm/capistrano"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :rvm_ruby_string, '2.0.0'
set :rvm_type, :user
set :rvm_require_role, :app

set :application, 'joint_ink'
set :rack_env, "production"
set :app1_domain, '97.107.133.156' # replace with app1.jointink.com when dns is setup
set :db1_domain, '96.126.111.109' # replace with db1.jointink.com when dns is setup

# roles (servers)
role :web, app1_domain
role :app, app1_domain
role :db,  app1_domain, :primary => true

set :scm, :git
set :scm_verbose, true
set :repository,  'https://marbemac@github.com/evario/JointInk.git'
set :branch,  'master'
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 3
set :user, 'deployer'

namespace :deploy do
  desc "Restart Passenger"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "update permissions"
  task :update_permissions, :roles => :app do
    run "cd #{release_path} && chmod -R 777 tmp"
  end

  desc "link database file"
  task :link_db_file, :roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:setup' do
  sudo "chown -R #{user} #{deploy_to} && chmod -R g+s #{deploy_to}"
end
after "deploy:update_code", "deploy:update_permissions"
before "deploy:assets:precompile", "deploy:link_db_file"

desc "tail production log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

namespace :rails do
  desc "Open the rails console on one of the remote servers"
  task :console, :roles => :app do
    run "#{current_path}/script/rails c #{rails_env}"
  end
end