module LuckyColorController
  extend self

  LUCKY_COLOR_WORDS = %w(イラスト 花 デザート フルーツ 魚 ケーキ 車 本 飲み物 野菜 かわいい動物 dragon-quest-monsters splatoon-weapon splatoon-characters マリオ 植物 惑星 ドラゴン 悪魔 ディズニーキャラクター 日用品 旗 メガネ 鼻眼鏡 歴史上の人物 帽子 ワンピース服 パン パスタ ピエロ ギター 笛 えんぴつ ボールペン 飴 マグカップ 夜景 スマホケース カバン イヤホン 飛行機 グミ 伝説上の生き物 ぬいぐるみ 座布団 靴 服)
  LUCKY_COLOR_JAPANESE = %w(黒 青 茶 灰 緑 橙 桃 紫 赤 青緑 白 黄)
  LUCKY_COLOR_ENGLISH = %w(black blue brown gray green orange pink purple red teal white yellow)

  def do(message_event)
    Activity.add(message_event.author, :lucky_color)

    lucky_color_index = rand(LUCKY_COLOR_JAPANESE.count)
    http = HTTP.get("https://www.googleapis.com/customsearch/v1", params: {key: ENV['DISCORD_BOT_GOOGLE_API_KEY'], cx: ENV['DISCORD_BOT_GOOGLE_API_CX'], q: "#{LUCKY_COLOR_WORDS.sample}", num: 1, start: rand(10)+1, searchType: "image", imgDominantColor: LUCKY_COLOR_ENGLISH[lucky_color_index]})
    if http.status != 200
      message_event.send_message(I18n.t('lucky_color.error'))
      return
    end
    response = JSON.parse(http.body)
    photo_source = response['items'].sample
    path = "tmp/cache/image.jpg"
    OpenURI.open_uri(photo_source["link"]) { |image|
      File.open(path, "wb") do |file| file.puts image.read; end
    }
    message_event.send_message(I18n.t('lucky_color.display', name: message_event.author.display_name, color: LUCKY_COLOR_JAPANESE[lucky_color_index]))
    message_event.send_file(File.open(path, "r"))
    File.delete(path)
  end
end
