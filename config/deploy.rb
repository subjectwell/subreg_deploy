# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'subreg'
set :repo_url, 'git@github.com:subjectwell/subreg.git'
set :deploy_to, '/var/www/vhost/subreg'
set :scm, :git
set :pty, false
set :keep_releases, 5
set :passenger_roles, :web

set :bundle_without, 'development test assets'

### Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
### Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
### Default value for :format is :airbrussh.
# set :format, :airbrussh
### You can configure the Airbrussh format using :format_options.
### These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/param_keys.yml', 'config/atana_api.yml'
append :linked_dirs, 'log'

namespace :deploy do
  after :finished, 'airbrake:deploy'
end