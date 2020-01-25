module WeatherController
  extend self

  def get(message_event)
    if ENV['DISCORD_BOT_GEOCODE_APPID'].blank? || ENV['DISCORD_BOT_WEATHER_APPID'].blank?
      STDERR.puts "Undefined Variable: DISCORD_BOT_GEOCODE_APPID or DISCORD_BOT_WEATHER_APPID"
      return
    end

    Activity.add(message_event.author, :weather)

    qurty_string = message_event.content.match(Settings::WEATHER_RESPONSE)[1]
    geocode_response = HTTP.get("https://map.yahooapis.jp/geocode/V1/geoCoder", params: {output: "json", appid: ENV['DISCORD_BOT_GEOCODE_APPID'], query: qurty_string, al: 3, ar: "le"})
    return if geocode_response.status != 200 || JSON.parse(geocode_response)['Feature'].blank?
    city = JSON.parse(geocode_response)['Feature'].sample
    lon, lat = city['Geometry']['Coordinates'].split(",")
    weather_response = HTTP.get("https://api.openweathermap.org/data/2.5/weather", params: {appid: ENV['DISCORD_BOT_WEATHER_APPID'], lat: lat.to_f, lon: lon.to_f})
    return if weather_response.status != 200
    weather = JSON.parse(weather_response)
    temp = "%.1f" % (weather['main']['temp'].to_f - 273.15)
    temp_max = "%.1f" % (weather['main']['temp_max'].to_f - 273.15)
    temp_min = "%.1f" % (weather['main']['temp_min'].to_f - 273.15)
    weather_patterns = I18n.t('weather.patterns').map(&:split).to_h
    weather_string = weather_patterns[weather['weather'].first['id'].to_s]
    res = []
    res << I18n.t('weather.title.weather', weather: weather_string)
    res << I18n.t('weather.title.temp', temp: temp, temp_min: temp_min, temp_max: temp_max)
    res << I18n.t('weather.title.humidity', humidity: weather['main']['humidity'])
    res << I18n.t('weather.title.pressure', pressure: weather['main']['pressure'])
    res << I18n.t('weather.title.speed', speed: weather['wind']['speed'])
    res << I18n.t('weather.title.sunrise', sunrise: Time.at(weather['sys']['sunrise']).strftime('%H:%M'))
    res << I18n.t('weather.title.sunset', sunset: Time.at(weather['sys']['sunset']).strftime('%H:%M'))
    message_event.channel.send_embed do |embed|
      embed.title = "#{city['Name']}#{I18n.t('weather.display')}"
      embed.description = res.join("\n")
      embed.color = 0x5882FA
    end
  end
end
