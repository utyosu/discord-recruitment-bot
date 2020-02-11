class WeatherAction
  DIFF_TO_ABSOLUTE_ZERO = 273.15

  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.weather)
  end

  def execute(message_event)
    if Settings.secret.yahoo_geocode_api.appid.blank? || Settings.secret.open_weather_map.appid.blank?
      Logger.new(STDOUT).puts "Need settings: yahoo_geocode_api.appid and open_weather_map.appid"
      return
    end

    Activity.add(message_event.author, :weather)

    qurty_string = message_event.content.gsub(Regexp.new(Settings.keyword.weather.join('|')), '')
    geocode_response = HTTP.get(
      "https://map.yahooapis.jp/geocode/V1/geoCoder",
      params: {
        output: "json",
        appid: Settings.secret.yahoo_geocode_api.appid,
        query: qurty_string,
        al: 3,
        ar: "le",
      }
    )
    return if geocode_response.status != 200 || JSON.parse(geocode_response)['Feature'].blank?
    city = JSON.parse(geocode_response)['Feature'].sample
    lon, lat = city['Geometry']['Coordinates'].split(",")
    weather_response = HTTP.get("https://api.openweathermap.org/data/2.5/weather", params: { appid: Settings.secret.open_weather_map.appid, lat: lat.to_f, lon: lon.to_f })
    return if weather_response.status != 200
    weather = JSON.parse(weather_response)
    temp = format("%<temp>.1f", temp: (weather['main']['temp'].to_f - DIFF_TO_ABSOLUTE_ZERO))
    temp_max = format("%<temp_max>.1f", temp_max: (weather['main']['temp_max'].to_f - DIFF_TO_ABSOLUTE_ZERO))
    temp_min = format("%<temp_min>.1f", temp_min: (weather['main']['temp_min'].to_f - DIFF_TO_ABSOLUTE_ZERO))
    weather_patterns = Settings.weather.patterns.map(&:split).to_h
    weather_string = weather_patterns[weather['weather'].first['id'].to_s]
    res = []
    res << I18n.t('weather.title.weather', weather: weather_string)
    res << I18n.t('weather.title.temp', temp: temp, temp_min: temp_min, temp_max: temp_max)
    res << I18n.t('weather.title.humidity', humidity: weather['main']['humidity'])
    res << I18n.t('weather.title.pressure', pressure: weather['main']['pressure'])
    res << I18n.t('weather.title.speed', speed: weather['wind']['speed'])
    res << I18n.t('weather.title.sunrise', sunrise: Time.zone.at(weather['sys']['sunrise']).strftime('%H:%M'))
    res << I18n.t('weather.title.sunset', sunset: Time.zone.at(weather['sys']['sunset']).strftime('%H:%M'))
    message_event.channel.send_embed do |embed|
      embed.title = "#{city['Name']}#{I18n.t('weather.display')}"
      embed.description = res.join("\n")
      embed.color = 0x5882FA
    end
  end
end
