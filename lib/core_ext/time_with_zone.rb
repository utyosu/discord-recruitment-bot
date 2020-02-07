module ActiveSupport
  class TimeWithZone
    def to_simply
      return self.strftime("%H:%M") if self.to_date == Time.zone.today
      return self.strftime("%m/%d %H:%M") if self.year == Time.zone.today.year
      self.strftime("%Y/%m/%d %H:%M")
    end
  end
end
