require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
require "capistrano/rails"
require "capistrano/bundler"
require "capistrano/puma"
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Daemon
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
