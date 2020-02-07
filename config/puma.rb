proj_path = "#{File.expand_path('..', __dir__)}"
proj_name = File.basename(proj_path)

threads_count = ENV.fetch("RAILS_MAX_THREADS") { 8 }.to_i
threads threads_count, threads_count

pid_dir = "/var/tmp/pids"
sock_dir = "/var/tmp/sockets"

FileUtils.mkdir_p(pid_dir)
FileUtils.mkdir_p(sock_dir)

pidfile "#{pid_dir}/#{proj_name}.pid"
bind "unix://#{sock_dir}/#{proj_name}.sock"
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart
