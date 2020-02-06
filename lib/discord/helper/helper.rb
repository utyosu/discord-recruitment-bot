module Helper
  extend self

  def to_safe(str)
    # <@\d+> is discord mention
    str.tr('０-９ａ-ｚＡ-Ｚ＠？：', '0-9a-zA-Z@?:').gsub(/<@\d+>/, "").gsub(/[[:blank:]]/, " ")
  end

  def get_message_content(message_event)
    message_event.content.gsub(/\r\n|\r|\n/, "")
  end

  def send_message_command(message_event, bot)
    command, channel_name, message = message_event.content.split(" ", 3)
    return if message.blank?
    channel = bot.servers.map { |server_id, server| server.channels.find { |channel| channel.name == channel_name } }.first
    channel.send_message(message) if channel.present?
  end

  def get_channel(bot, channel_id)
    bot.servers.map { |_server_id, server| server.channels }.flatten.find { |channel| channel.id == channel_id.to_i }
  end

  def pm?(message_event)
    message_event.channel.pm?
  end

  def recruitment?(message_event)
    message_event.channel.id == Settings.secret.discord.recruitment_channel_id.to_i
  end

  def play?(message_event)
    message_event.channel.id == Settings.secret.discord.play_channel_id.to_i
  end
end
