class Extractor
  def self.extraction_time(str)
    adjust_alright(base(str), str)
  end

  def self.extraction_recruit_user_count(str)
    tmp = Helper.to_safe(str).gsub(/\d+時|\d+:\d+/, "").match(/@\d+[^\d]+(\d+)/)
    return tmp[1].to_i if tmp.present?
    tmp = Helper.to_safe(str).match(/@(\d+)/)
    return tmp.blank? ? nil : tmp[1].to_i
  end

  def self.extraction_number(str)
    num_list = Helper.to_safe(str).gsub(/[^\d]/, ",").gsub(/,+/, ",").gsub(/^,/, "").gsub(/,$/, "").split(",").map(&:to_i)
    return num_list.first if num_list.size == 1
    return 0 if num_list.size == 0
    return nil
  end

  private

  def self.base(str)
    # trimming
    str = str.gsub(/(\d+時|\d+:\d+)[^\d]*まで/, "").gsub(/[～-](\d+時|\d+:\d+)/, "")

    # yyyy/mm/dd hh:mm style
    begin
      return Helper.to_safe(str).slice(/\d{4}\/\d{1,2}\/\d{1,2}\s+\d{1,2}:\d{2}/).in_time_zone
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # mm/dd hh:mm style
    begin
      return Helper.to_safe(str).slice(/\d{1,2}\/\d{1,2}\s+\d{1,2}:\d{2}/).in_time_zone
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # hh:mm style
    begin
      match = Helper.to_safe(str).match(/(\d{1,2}):(\d{2})/)
      return to_datetime(match[1], match[2]) if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時m分 style
    begin
      match = Helper.to_safe(str).match(/(\d{1,2})時(\d{1,2})分/)
      return to_datetime(match[1], match[2]) if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時半 style
    begin
      match = Helper.to_safe(str).gsub(/\d{1,2}時間/, "").match(/(\d{1,2})時半/)
      return to_datetime(match[1], "30") if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # n時 style
    begin
      match = Helper.to_safe(str).gsub(/\d{1,2}時間/, "").match(/(\d{1,2})時/)
      return to_datetime(match[1], "00") if match
    rescue ArgumentError, NoMethodError => e
      # do nothing
    end

    # Old Japanese Style
    if str =~ /丑三つ時/
      datetime = Time.zone.parse("02:00")
      datetime += 24.hours if datetime < Time.zone.now
      return datetime
    end

    return nil
  end

  def self.to_datetime(hour, min)
    raise ArgumentError if hour.blank? || min.blank?
    if 24 <= hour.to_i
      return "#{hour.to_i - 24}:#{min}".in_time_zone + 24.hours
    else
      return "#{hour}:#{min}".in_time_zone
    end
  end

  def self.adjust_alright(datetime, str)
    return datetime if datetime.blank?

    datetime += 24.hours if str =~ /明日/

    # 時間が過ぎている
    if datetime.hour < 12
      2.times { datetime += 12.hours if datetime < Time.zone.now }
    else
      datetime += 24.hours if datetime < Time.zone.now
    end

    return datetime
  end
end
