require 'bundler/capistrano'
require "rvm/capistrano"

# RVM
set :rvm_ruby_string, '2.0.0-p195'
set :rvm_type, :user
set :user, 'deployer'
set :keep_releases, 3

default_run_options[:pty] = true
ssh_options[:forward_agent] = false

# SCM
set :application,         'joint_ink'
set :rack_env, "production"
set :repository,          'git@github.com:evario/JointInk.git'
set :branch,              "master"
set :user,                "deployer"
set :scm,                 :git
set :scm_verbose,         true
set :use_sudo,            false

# roles (servers)
set :application, 'joint_ink'
set :app1_domain, '97.107.133.156'
set :app2_domain, '97.107.130.51'
set :db1_domain, '96.126.111.109'
role :web, app1_domain, app2_domain
role :app, app1_domain, app2_domain
role :db,  app1_domain, :primary => true

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
after "deploy:restart", "deploy:cleanup"