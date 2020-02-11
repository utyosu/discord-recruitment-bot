class WeatherAction
  DIFF_TO_ABSOLUTE_ZERO = 273.15

  def execute?(message_event)
    message_event.play? &&
      message_event.match_any_keywords?(Settings.keyword.weather) &&
      Settings.secret.yahoo_geocode_api.appid.present? &&
      Settings.secret.open_weather_map.appid.present?
  end

  def execute(message_event)
    Activity.add(message_event.author, :weather)

    city_word = message_event.content.gsub(Regexp.new(Settings.keyword.weather.join("|")), "")

    city = city_from_word(city_word)
    return if city.blank?

    weather = weather_from_position(city[:lon], city[:lat])
    message_event.channel.send_embed do |embed|
      embed.title = "#{city[:name]}#{I18n.t("weather.display")}"
      embed.description = I18n.t("weather.format", weather_to_hash(weather))
      embed.color = 0x5882FA
    end
  end

  def weather_to_hash(weather)
    {
      weather: Settings.weather.patterns.map(&:split).to_h[weather["weather"].first["id"].to_s],
      temp: format("%<temp>.1f", temp: (weather["main"]["temp"].to_f - DIFF_TO_ABSOLUTE_ZERO)),
      temp_max: format("%<temp_max>.1f", temp_max: (weather["main"]["temp_max"].to_f - DIFF_TO_ABSOLUTE_ZERO)),
      temp_min: format("%<temp_min>.1f", temp_min: (weather["main"]["temp_min"].to_f - DIFF_TO_ABSOLUTE_ZERO)),
      humidity: weather["main"]["humidity"],
      pressure: weather["main"]["pressure"],
      speed: weather["wind"]["speed"],
      sunrise: Time.zone.at(weather["sys"]["sunrise"]).strftime("%H:%M"),
      sunset: Time.zone.at(weather["sys"]["sunset"]).strftime("%H:%M"),
    }
  end

  def city_from_word(word)
    geocode_response = HTTP.get(
      "https://map.yahooapis.jp/geocode/V1/geoCoder",
      params: {
        output: "json",
        appid: Settings.secret.yahoo_geocode_api.appid,
        query: word,
        al: 3,
        ar: "le",
      }
    )
    return nil if geocode_response.status != 200 || JSON.parse(geocode_response)["Feature"].blank?
    city = JSON.parse(geocode_response)["Feature"].sample
    lon, lat = city["Geometry"]["Coordinates"].split(",")
    return {
      name: city["Name"],
      lon: lon,
      lat: lat,
    }
  end

  def weather_from_position(lon, lat)
    weather_response = HTTP.get(
      "https://api.openweathermap.org/data/2.5/weather",
      params: {
        appid: Settings.secret.open_weather_map.appid,
        lat: lat.to_f,
        lon: lon.to_f,
      }
    )
    return if weather_response.status != 200
    return JSON.parse(weather_response)
  end
end
