# config valid only for current version of Capistrano
lock '3.8.2'

set :application, 'ants'
set :repo_url, 'git@github.com:subjectwell/ants.git'
set :deploy_to, '/var/deploy/apps/ants'
set :scm, :git
set :pty, false
set :keep_releases, 5
set :bundle_without, 'development test assets'

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/puma.rb', 'config/cable.yml'
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
      execute "/usr/local/etc/rc.d/puma restart"
    end
  end

  after :finishing, :restart
end
