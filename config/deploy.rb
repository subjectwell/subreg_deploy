# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'subreg'
set :repo_url, 'git@github.com:subjectwell/subreg.git'
set :deploy_to, '/var/deploy/apps/subreg'
set :scm, :git
set :pty, false
set :keep_releases, 5
set :bundle_without, 'development test assets'

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/param_keys.yml', 'config/atana_api.yml'
append :linked_dirs, 'log'