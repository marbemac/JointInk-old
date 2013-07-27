require 'torquebox-capistrano-support'
require 'bundler/capistrano'

default_run_options[:pty] = true

# SCM
set :application,         'joint_ink'
set :repository,          'git@github.com:evario/JointInk.git'
set :branch,              "torquebox"
set :user,                "deployer"
set :scm,                 :git
set :scm_verbose,         true
set :use_sudo,            false

# Production server
set :deploy_to,           "/home/torquebox/#{application}"
set :deploy_via,          :remote_cache
set :keep_releases,       3
set :torquebox_home,      '/opt/torquebox/current'
set :jboss_control_style, :binscripts
set :app_environment,     {:RAILS_ENV => 'production'}
set :rails_env,           "production"
set :app_context,         "/"
set :default_environment, {
    'PATH' => "/opt/torquebox/current/jruby/bin:$PATH"
}

ssh_options[:forward_agent] = false

set :app1_domain, '162.216.19.26'
set :db1_domain, '96.126.111.109'
role :web, app1_domain
role :app, app1_domain
role :db,  app1_domain, :primary => true

namespace :deploy do
  #desc "Restart Passenger"
  #task :restart, :roles => :app, :except => { :no_release => true } do
  #  run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  #end

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