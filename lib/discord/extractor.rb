class Extractor
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

  TIME_PATTERN = [
    [/(?<year>\d{4})\/(?<month>\d{1,2})\/(?<day>\d{1,2})\s+(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<month>\d{1,2})\/(?<day>\d{1,2})\s+(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<hour>\d{1,2})時(?<min>\d{1,2})分/],
    [/(?<hour>\d{1,2})時半/, ->(time) { time.merge!(min: 30) }],
    [/(?<hour>\d{1,2})時(?!間)/],
    [/丑三つ時/, ->(time) { time.merge!(day: time[:day] + 1, hour: 2) }]
  ]

  DECORATIVE_PATTERN = [
    [/明日/, ->(time) { time.merge!(day: time[:day] + 1) }]
  ]

  def self.extraction_time(str)
    # trimming
    str = Helper.to_safe(str.gsub(/(\d+時|\d+:\d+)[^\d]*まで/, "").gsub(/[～-](\d+時|\d+:\d+)/, ""))

    TIME_PATTERN.each do |pattern, function|
      match = str.match(pattern)
      next if match.blank?
      match_time = match&.named_captures&.with_indifferent_access
      now = Time.zone.now
      time = {
        year: (match_time[:year] || now.year).to_i,
        month: (match_time[:month] || now.month).to_i,
        day: (match_time[:day] || now.day).to_i,
        hour: (match_time[:hour] || now.hour).to_i,
        min: (match_time[:min] || now.min).to_i,
      }

      time[:day] += time[:hour] / 24
      time[:hour] %= 24

      function.call(time) if function.present?

      apply_decorate(str, time)

      datetime = Time.new(time[:year], time[:month], time[:day], time[:hour], time[:min]).in_time_zone

      return to_future(datetime)
    end

    return nil
  end

  def self.apply_decorate(str, time)
    DECORATIVE_PATTERN.each do |pattern, function|
      function.call(time) if str.match(pattern)
    end
  end

  def self.to_future(datetime)
    diff_sec = Time.zone.now - datetime
    if diff_sec > 0
      if datetime.hour < 12 && diff_sec < 12.hours
        datetime += 12.hours
      elsif diff_sec < 24.hours
        datetime += 24.hours
      end
    end

    return datetime
  end
end
