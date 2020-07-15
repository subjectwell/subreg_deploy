# config valid only for current version of Capistrano
lock '3.11.0'

set :application, 'subreg'
set :repo_url, 'git@github.com:subjectwell/subreg.git'
set :deploy_to, '/var/deploy/apps/subreg'
set :branch do
  ask( "subreg tag to deploy: " )
end
set :pty, false
set :keep_releases, 5
# Run db migrations if there are any on servers with the role db (cron)
set :migration_role, :db
set :bundle_without, 'development test assets'

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/param_keys.yml', 'config/atana_api.yml', 'config/puma.rb', 'config/smtp.yml'
append :linked_dirs, 'log', 'tmp'

namespace :deploy do
  desc 'Ensure pids dir is there'
  task :ensure_pids do
    on roles( :all ) do
      execute "/bin/mkdir -p #{ shared_path }/tmp/pids"
    end
  end

  after 'deploy:started', :ensure_pids

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /usr/local/etc/rc.d/puma restart"
    end
  end

  after :finishing, :restart
  after :finished, 'airbrake:deploy'
end
