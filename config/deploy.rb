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
on roles( :app ) do
  set :bundle_without, 'development test'
end
on roles( :cron ) do
  set :bundle_without, 'development test assets'
end

set :assets_roles, [ :app ]

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/param_keys.yml', 'config/atana_api.yml', 'config/puma.rb', 'config/smtp.yml'
append :linked_dirs, 'log', 'tmp'

namespace :frontend do
  deploy_to_dir = "/var/deploy/apps/subreg/current/public/signup"
  git = "/usr/local/bin/git"
  npm = "/usr/local/bin/npm"

  code_dir = File.expand_path("~/subreg/frontend")
  checkout_dir = File.expand_path("~/subreg")

  desc 'Update frontend app'
  task :update do
    %x(cd #{checkout_dir} && #{git} checkout #{fetch(:branch)} && #{git} pull)
  end

  desc 'Build Vue Apps'
  task :build do
    %x(cd #{code_dir} && rm -rf dist) &&
        $?.exitstatus == 0 &&
        %x(cd #{code_dir} && #{npm} ci --only=prod) &&
        $?.exitstatus == 0 &&
        %x(cd #{code_dir} && #{npm} prune) &&
        $?.exitstatus == 0 &&
        %x(cd #{code_dir} && #{npm} run build) ||
        raise( "An error occurred while building the Vue apps" )
  end

  desc 'Upload App'
  task :upload do
    on roles(:all) do
      Dir.glob( code_dir + "/dist/*" ).each do | f |
        upload! f, deploy_to_dir, recursive: true, mkdir: true
      end
    end
  end

  desc 'Deploy the UI app'
  task :deploy do
    invoke 'frontend:update'
    invoke 'frontend:build'
    invoke 'frontend:upload'
  end
end

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

  after :finishing, 'frontend:deploy'
  after :finishing, :restart
  after :finished, 'airbrake:deploy'
end
