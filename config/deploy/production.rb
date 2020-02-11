role :app, %w[ops@gce]

server "gce", user: "ops", roles: %w[app]

set :rails_env, :production
