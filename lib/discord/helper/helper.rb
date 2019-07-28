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
