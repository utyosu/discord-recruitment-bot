module WeatherController
  extend self

  WEATHER_PATTERNS = {
    '200' => '小雨による雷雨',
    '201' => '雨による雷雨',
    '202' => '豪雨による雷雨',
    '210' => '小さい雷雨',
    '211' => '雷雨',
    '212' => '激しい雷雨',
    '221' => 'ぼろぼろの雷雨',
    '230' => '小さい霧雨による雷雨',
    '231' => '霧雨による雷雨',
    '232' => 'ひどい霧雨による雷雨',
    '300' => '光度霧雨',
    '301' => '霧雨',
    '302' => 'ひどい強さ霧雨',
    '310' => '光度霧雨雨',
    '311' => '霧雨雨',
    '312' => 'ひどい強さ霧雨雨',
    '313' => 'シャワー雨と霧雨',
    '314' => 'ひどいシャワー雨と霧雨',
    '321' => 'シャワー霧雨',
    '500' => '小雨',
    '501' => '穏やかな雨',
    '502' => 'ひどい強さ雨',
    '503' => '非常にひどい雨',
    '504' => '最大の雨',
    '511' => '凍るような雨',
    '520' => '光度シャワー雨',
    '521' => 'シャワー雨',
    '522' => 'ひどい強さシャワー雨',
    '531' => 'ぼろぼろのシャワー雨',
    '600' => '小雪',
    '601' => '雪',
    '602' => '大雪',
    '611' => 'みぞれ',
    '612' => 'シャワーみぞれ',
    '615' => '小雨と雪',
    '616' => '雨と雪',
    '620' => '小さいシャワー雪',
    '621' => 'シャワー雪',
    '622' => 'ひどいシャワー雪',
    '701' => '霧',
    '711' => '煙',
    '721' => 'もや',
    '731' => '砂、塵旋風',
    '741' => '霧',
    '751' => '砂',
    '761' => 'ちり',
    '762' => '火山灰',
    '771' => 'スコール',
    '781' => '竜巻',
    '800' => '晴天',
    '801' => 'ほとんど雲でない',
    '802' => '千切れ雲',
    '803' => '壊れた雲',
    '804' => '曇った雲',
    '900' => '竜巻',
    '901' => '熱帯低気圧',
    '902' => 'ハリケーン',
    '903' => '寒冷',
    '904' => '高温',
    '905' => '風が強い',
    '906' => 'ひょう',
    '951' => '落ちつき',
    '952' => '軽風',
    '953' => '軟風',
    '954' => '和風',
    '955' => '疾風',
    '956' => '雄風',
    '957' => '強風、強風',
    '958' => '強風',
    '959' => '厳しい強風',
    '960' => '嵐',
    '961' => '暴風',
    '962' => 'ハリケーン',
  }

  def get(message_event)
    if ENV['DISCORD_BOT_GEOCODE_APPID'].blank? || ENV['DISCORD_BOT_WEATHER_APPID'].blank?
      STDERR.puts "DISCORD_BOT_GEOCODE_APPID もしくは DISCORD_BOT_WEATHER_APPID が未定義です。"
      return
    end
    return if !check_limit(message_event, "weather", 3)
    qurty_string = message_event.content.match($KEYWORDS_WEATHER_RESPONSE)[1]
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
    weather_string = WEATHER_PATTERNS[weather['weather'].first['id'].to_s]
    res = []
    res << "#{city['Name']}の天気"
    res << "天気 : #{weather_string}"
    res << "気温 : #{temp}度 (#{temp_min}度～#{temp_max}度)"
    res << "湿度 : #{weather['main']['humidity']}%"
    res << "気圧 : #{weather['main']['pressure']} hPa"
    res << "風速 : #{weather['wind']['speed']} m/s"
    res << "日の出 : #{Time.at(weather['sys']['sunrise']).strftime('%H:%M')}"
    res << "日の入 : #{Time.at(weather['sys']['sunset']).strftime('%H:%M')}"
    message_event.send_message("```\n#{res.join("\n")}\n```")
  end
end
