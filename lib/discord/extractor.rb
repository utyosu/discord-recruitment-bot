class Extractor
  def self.extraction_time(str)
    adjust_alright(base(str), str)
  end

  def self.extraction_recruit_user_count(str)
    tmp = to_safe(str).gsub(/\d+時|\d+:\d+/,"").match(/@\d+[^\d]+(\d+)/)
    return tmp[1].to_i if tmp.present?
    tmp = to_safe(str).match(/@(\d+)/)
    return tmp.blank? ? nil : tmp[1].to_i
  end

  def self.extraction_number(str)
    num_list = to_safe(str).gsub(/[^\d]/,",").gsub(/,+/,",").gsub(/^,/,"").gsub(/,$/,"").split(",").map(&:to_i)
    return num_list.first if num_list.size == 1
    return 0 if num_list.size == 0
    return nil
  end

  private

  def self.base(str)
    # trimming
    str = str.gsub(/(\d+時|\d+:\d+)[^\d]*まで/, "")
    str = str.gsub(/[～-](\d+時|\d+:\d+)/, "")

    # yyyy/mm/dd hh:mm style
    begin
      return to_safe(str).slice(/\d{4}\/\d{1,2}\/\d{1,2}\s+\d{1,2}:\d{2}/).in_time_zone
    rescue ArgumentError, NoMethodError => e
    end

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

    # 「明日」というキーワードがあれば24時間足す
    if str =~ /明日/
      datetime += 60 * 60 * 24
    end

    # 時間が過ぎている
    2.times{datetime += 60 * 60 * 12 if datetime < Time.zone.now}

    return datetime
  end
end
