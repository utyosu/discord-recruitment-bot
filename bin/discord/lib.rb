def update_recruitment(recruitment)
  JSON.parse(Api::Recruitment.index.body).find{|r|r['id'] == recruitment['id']}
end

def build_mention_from_participants(participants)
  participants.map{|p|"<@#{p['discord_id']}>"}.join(" ")
end

def to_safe(str)
  # <@\d+> is discord mention
  str.tr('０-９ａ-ｚＡ-Ｚ＠？：', '0-9a-zA-Z@?:').gsub(/<@\d+>/, "")
end

def extraction_recruit_user_count(str)
  tmp = to_safe(str).gsub(/\d+時|\d+:\d+/,"").match(/@\d+[^\d]+(\d+)/)
  return tmp[1].to_i if tmp.present?
  tmp = to_safe(str).match(/@(\d+)/)
  return tmp.blank? ? nil : tmp[1].to_i
end

def extraction_number(str)
  tmp = to_safe(str).gsub(/[^\d]/, "")
  return tmp.to_i if tmp =~ /\d/
  return nil
end

def extraction_time(str)
  ExtractionTime.extraction(str)
end

def view_datetime(input)
  datetime = input.in_time_zone
  if datetime.to_date == Date.today
    datetime.strftime("%H:%M")
  else
    datetime.strftime("%m/%d %H:%M")
  end
end

def match_keywords(message_event, keywords)
  to_safe(get_message_content(message_event)) =~ keywords
end

def get_message_content(message_event)
  message_event.content.split(/\r\n|\r|\n/).first
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
  message_event.send_message("#{ENV['DISCORD_BOT_TALK_WORD']}でばかり遊んでいないで、リーグかサーモンの募集をしてはどうですか？")
  return false
end

class ExtractionTime
  def self.extraction(str)
    adjust_alright(base(str), str)
  end

  private

  def self.base(str)
    # trimming
    str = str.gsub(/(\d+時|\d+:\d+)[^\d]*まで/, "")
    str = str.gsub(/[～-](\d+時|\d+:\d+)/, "")

    # mm/dd hh:mm style
    begin
      return to_safe(str).slice(/\d{1,2}\/\d{1,2}\s+\d{1,2}:\d{2}/).in_time_zone
    rescue ArgumentError, NoMethodError => e
    end

    # hh:mm style
    begin
      match = to_safe(str).match(/(\d{1,2}):(\d{2})/)
      return to_datetime(match[1], match[2]) if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時m分 style
    begin
      match = to_safe(str).match(/(\d{1,2})時(\d{1,2})分/)
      return to_datetime(match[1], match[2]) if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時半 style
    begin
      match = to_safe(str).gsub(/\d{1,2}時間/, "").match(/(\d{1,2})時半/)
      return to_datetime(match[1], "30") if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時 style
    begin
      match = to_safe(str).gsub(/\d{1,2}時間/, "").match(/(\d{1,2})時/)
      return to_datetime(match[1], "00") if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # Old Japanese Style
    if str =~ /丑三つ時/
      datetime = Time.zone.parse("02:00")
      datetime += (60 * 60 * 24) if datetime < Time.zone.now
      return datetime
    end

    return nil
  end

  def self.to_datetime(hour, min)
    raise ArgumentError if hour.blank? || min.blank?
    if 24 <= hour.to_i
      return "#{hour.to_i-24}:#{min}".in_time_zone + (60 * 60 * 24)
    else
      return "#{hour}:#{min}".in_time_zone
    end
  end

  def self.adjust_alright(datetime, str)
    return datetime if datetime.blank?

    # 「明日」というキーワードがあれば12時間足す
    if str =~ /明日/
      datetime += 60 * 60 * 24
    end

    # 時間が過ぎている
    2.times{datetime += 60 * 60 * 12 if datetime < Time.zone.now}

    return datetime
  end
end
