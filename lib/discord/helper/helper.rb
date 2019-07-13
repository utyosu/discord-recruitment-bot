def update_recruitment(recruitment)
  JSON.parse(Api::Recruitment.index.body).find{|r|r['id'] == recruitment['id']}
end

def to_safe(str)
  # <@\d+> is discord mention
  str.tr('０-９ａ-ｚＡ-Ｚ＠？：', '0-9a-zA-Z@?:').gsub(/<@\d+>/, "").gsub(/[[:blank:]]/, " ")
end

def get_message_content(message_event)
  message_event.content.gsub(/\r\n|\r|\n/, "")
end

def send_message_command(message_event)
  command, channel_name, message = message_event.content.split(" ", 3)
  return if message.blank?
  channel = $bot.servers.map{|server_id, server| server.channels.find{|channel| channel.name == channel_name}}.first
  channel.send_message(message) if channel.present?
end

def check_limit(message_event, type, limit)
  refresh_time = 8
  user = JSON.parse(Api::User.get_from_discord_id(message_event.author.id).body)
  last_at = user["#{type}_at"].in_time_zone rescue (Time.zone.now - (60 * 60 * 24))
  refresh_at = (Time.zone.now - (60 * 60 * refresh_time)).to_date.in_time_zone + (60 * 60 * refresh_time)
  user["#{type}_count"] = 0 if last_at < refresh_at
  if user["#{type}_count"].to_i < limit.to_i
    user["#{type}_count"] = user["#{type}_count"].to_i + 1
    user["#{type}_at"] = Time.zone.now.to_s
    Api::User.update(user)
    return true
  end
  message_event.send_message("#{ENV['DISCORD_BOT_TALK_WARNING_MESSAGE']}")
  return false
end
