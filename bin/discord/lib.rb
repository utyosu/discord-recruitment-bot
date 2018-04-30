def to_safe(str)
  str.tr('０-９ａ-ｚＡ-Ｚ＠？：', '0-9a-zA-Z@?:').gsub(/<@\d+>/, "")
end

def extraction_number(str)
  to_safe(str).gsub(/[^\d]/, "").to_i
end

def extraction_expired_time(str)
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
    return to_safe(str).slice(/\d{1,2}時半?/).gsub(/時半/,":30").gsub(/時/,":00").in_time_zone
  rescue ArgumentError, NoMethodError => e
    # do nothing
  end

  return DateTime.now + Rational(1, 24)
end

def view_datetime(input)
  datetime = input.in_time_zone
  if datetime.to_date == Date.today
    datetime.strftime("本日 %H:%M")
  else
    datetime.strftime("%m/%d %H:%M")
  end
end
