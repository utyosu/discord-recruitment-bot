# config valid for current version and patch releases of Capistrano
lock "~> 3.12.0"

set :application, "discord-recruitment-bot"
set :repo_url, "https://github.com/utyosu/discord-recruitment-bot"
set :branch, ENV["BRANCH"] || "master"

set :bundle_jobs, 1

set :puma_threads, [4, 16]
set :puma_workers, 0
set :pty, true
set :use_sudo, false
set :deploy_via, :remote_cache
set :deploy_to, "/home/ops/#{fetch(:application)}"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_daemonize, true

set :linked_dirs, fetch(:linked_dirs, []).push(
  "log",
  "tmp/pids",
  "tmp/cache",
  "tmp/sockets",
  "vendor/bundle",
  "public/system",
  "public/uploads",
)

namespace :puma do
  desc "Create Directories for Puma Pids and Socket"
  task :make_dirs do
    on roles(:app) do
      execute :mkdir, "#{shared_path}/tmp/sockets -p"
      execute :mkdir, "#{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end

namespace :deploy do
  task :compile_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rails, "assets:precompile"
        end
      end
    end
  end
  after :finishing, :compile_assets

  task :migrate_with_ridgepole do
    on roles(:app) do
      within release_path do
        execute :bundle, :exec, :ridgepole, "-c config/database.yml --apply -f db/schema -E #{fetch :rails_env}"
      end
    end
  end
  after :migrate, :migrate_with_ridgepole

  task :decrypt_settings do
    on roles(:app) do
      within release_path do
        execute :bundle, :exec, :yaml_vault, "decrypt config/settings/#{fetch :rails_env}.yml -o config/settings/#{fetch :rails_env}.local.yml"
      end
    end
  end
  before :migrate, :decrypt_settings
end

namespace :bot do
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :ruby, "bin/discord/bot.rb start"
        end
      end
    end
  end

  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :ruby, "bin/discord/bot.rb stop"
        end
      end
    end
  end

  task :restart do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :ruby, "bin/discord/bot.rb restart"
        end
      end
    end
  end
end

after "deploy:publishing", "bot:restart"
