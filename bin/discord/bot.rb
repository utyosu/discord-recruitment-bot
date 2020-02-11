BOT_DAEMONIZE = (ARGV[0] != "nodaemon")

# Load rails framework
require_relative "../../config/environment"

if ARGV[0] == "nodaemon"
  bot = Bot.new
  bot.start ARGV
else
  Bot.spawn!(
    working_dir: Rails.root,
    pid_file: "tmp/pids/discord_recruitment_bot_client.pid",
    log_file: "log/discord_recruitment_bot_client.log",
    sync_log: true,
    singleton: true,
  )
end
