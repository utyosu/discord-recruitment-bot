module ActiveSupport
  class TimeWithZone
    def to_simply
      return strftime("%H:%M") if to_date == Time.zone.today
      return strftime("%m/%d %H:%M") if year == Time.zone.today.year
      strftime("%Y/%m/%d %H:%M")
    end
  end
end
