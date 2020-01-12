role :app, %w{ops@gce}

server "gce",
  user: "ops",
  roles: %w{app},
  ssh_options: {
    user: "ops",
    keys: %w(/home/ops/.ssh/google_compute_engine),
    forward_agent: false,
    auth_methods: %w(publickey)
  }

set :rails_env, :production
