def update_recruitment(recruitment)
  JSON.parse(Api::Recruitment.index.body).find{|r|r['id'] == recruitment['id']}
end

def build_mention_from_participants(participants)
  participants.map{|p|"<@#{p['discord_id']}>"}.join(" ")
end

def to_safe(str)
  str.tr('０-９ａ-ｚＡ-Ｚ＠？：', '0-9a-zA-Z@?:').gsub(/<@\d+>/, "")
end

def extraction_recruit_user_count(str)
  tmp = to_safe(str).match(/@\d[^\d]+(\d)([^:時]|\Z)/)
  return tmp[1].to_i if tmp.present?
  tmp = to_safe(str).match(/@(\d+)/)
  return tmp.blank? ? nil : tmp[1].to_i
end

def extraction_number(str)
  tmp = to_safe(str).gsub(/[^\d]/, "")
  return tmp.to_i if tmp =~ /\d/
  return 1 if str =~ /one|ファースト|一|壱|Ⅰ/
  return 2 if str =~ /two|セカンド|二|弐|Ⅱ/
  return 3 if str =~ /three|サード|三|参|Ⅲ/
  return 4 if str =~ /four|フォース|四|肆|Ⅳ/
  return 5 if str =~ /five|フィフス|五|伍|Ⅴ/
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
  message = message_event.content.split(" ", 2)[1]
  return if message.blank?
  $recruitment_channel.send_message(message)
end

def send_message_all(message_event, message)
  message_event.send_message(message)
  $recruitment_channel.send_message(message) if message_event.channel.type == 1
end

class ExtractionTime
  def self.extraction(str)
    adjust_alright(base(str), str)
  end

  private

  def self.base(str)
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

    # n時 style
    begin
      match = to_safe(str).gsub(/\d{1,2}時間/, "").match(/(\d{1,2})時/)
      return to_datetime(match[1], "00") if match
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
