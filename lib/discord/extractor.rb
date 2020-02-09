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
    [/(?<year>\d{4})\/(?<mon>\d{1,2})\/(?<mday>\d{1,2})\s+(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<mon>\d{1,2})\/(?<mday>\d{1,2})\s+(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<hour>\d{1,2})時(?<min>\d{1,2})分/],
    [/(?<hour>\d{1,2})時半/, ->(time) { time.merge!(min: 30) }],
    [/(?<hour>\d{1,2})時(?!間)/],
    [/丑三つ時/, ->(time) { time.merge!(mday: time[:mday] + 1, hour: 2) }]
  ]

  DECORATIVE_PATTERN = [
    [/明日/, ->(time) { time.merge!(mday: time[:mday] + 1) }]
  ]

  def self.extraction_time(input)
    input = trim(input)
    TIME_PATTERN.each do |pattern, function|
      time = time_from_pattern(pattern, input)
      next if time.blank?
      carry_up(time)
      function.call(time) if function.present?
      apply_decorate(input, time)
      datetime = Time.zone.local(time[:year], time[:mon], time[:mday], time[:hour], time[:min])
      return to_future(datetime)
    end

    return nil
  end

  def self.trim(input)
    Helper.to_safe(input.gsub(/(\d+時|\d+:\d+)[^\d]*まで/, "").gsub(/[～-](\d+時|\d+:\d+)/, ""))
  end

  def self.time_from_pattern(pattern, input)
    match = input.match(pattern)
    return nil if match.blank?
    match_time = match.named_captures.map { |k, v| [k.to_sym, v.to_i] }.to_h
    DateTime._strptime(DateTime.now.to_s).merge(match_time)
  end

  def self.apply_decorate(input, time)
    DECORATIVE_PATTERN.each do |pattern, function|
      function.call(time) if input.match(pattern)
    end
  end

  def self.carry_up(time)
    time[:mday] += time[:hour] / 24
    time[:hour] %= 24
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
