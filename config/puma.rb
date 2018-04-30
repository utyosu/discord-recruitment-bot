_proj_path = "#{File.expand_path("../..", __FILE__)}"
_proj_name = File.basename(_proj_path)
puts _proj_name

threads_count = ENV.fetch("RAILS_MAX_THREADS") { 8 }.to_i
threads threads_count, threads_count

_pid_dir = "/var/tmp/pids"
_sock_dir = "/var/tmp/sockets"

FileUtils.mkdir_p(_pid_dir)
FileUtils.mkdir_p(_sock_dir)

pidfile "#{_pid_dir}/#{_proj_name}.pid"
bind "unix://#{_sock_dir}/#{_proj_name}.sock"
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart
