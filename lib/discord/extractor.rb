class Extractor
  def self.format(str)
    str
      .tr("０-９ａ-ｚＡ-Ｚ＠？：", "0-9a-zA-Z@?:") # 全角記号を半角にする
      .gsub(/<@\d+>/, "") # メンションを削除
      .gsub(/[[:blank:]]/, " ") # 空白類を全て半角スペース1つにする
      .gsub(/\R/, "") # 改行を削除
  end

  def self.extraction_recruit_user_count(str)
    format(str).scan(/@[^\s]+/).join.scan(/\d+/).map(&:to_i).max
  end

  TIME_PATTERN = [
    [/(?<year>\d{4})\/(?<mon>\d{1,2})\/(?<mday>\d{1,2})\s+(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<mon>\d{1,2})\/(?<mday>\d{1,2})\s+(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<hour>\d{1,2}):(?<min>\d{2})/],
    [/(?<hour>\d{1,2})時(?<min>\d{1,2})分/],
    [/(?<hour>\d{1,2})時半/, ->(time) { time.merge!(min: 30) }],
    [/(?<hour>\d{1,2})時(?!間)/, ->(time) { time.merge!(min: 0) }],
    [/丑三つ時/, ->(time) { time.merge!(mday: time[:mday] + 1, hour: 2, min: 0) }]
  ]

  DECORATIVE_PATTERN = [
    [/明日/, ->(time) { time.merge!(mday: time[:mday] + 1) }]
  ]

  def self.extraction_time(raw_input)
    input = exclude_end_time(format(raw_input))
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

  def self.exclude_end_time(input)
    input
      .gsub(/(\d+時|\d+:\d+)[^\d]*まで/, "")
      .gsub(/[～-](\d+時|\d+:\d+)/, "")
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
