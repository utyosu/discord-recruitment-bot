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
  tmp = to_safe(str).match(/@\d+(or|か)(\d)/)
  return tmp[2].to_i if tmp.present?
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
      return to_safe(str).slice(/\d{1,2}:\d{2}/).in_time_zone
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時m分 style
    begin
      return to_safe(str).slice(/\d{1,2}時\d{1,2}分/).gsub(/時/,":").gsub(/分/,"").in_time_zone
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時 style
    begin
      return to_safe(str).gsub(/\d{1,2}時間/, "").slice(/\d{1,2}時半?/).gsub(/時半/,":30").gsub(/時/,":00").in_time_zone
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

  def self.adjust_alright(datetime, str)
    return datetime if datetime.blank?

    # 「明日」というキーワードがあれば12時間足す
    if str =~ /明日/
      datetime += 60 * 60 * 24
    end

    # 1～12時で既に過ぎていたら12時間足す
    if 1 <= datetime.hour && datetime.hour <= 12 && datetime < Time.zone.now
      datetime += 60 * 60 * 12
    end

    return datetime
  end
end
