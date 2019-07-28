module FoodPornController
  extend self

  FOOD_WORDS = %w(焼き鳥 ラーメン パスタ うどん ステーキ ハンバーガー ケーキ パンケーキ パフェ 寿司 ピザ 焼き飯 チャーハン おにぎり てんぷら ドーナッツ 牛丼 ハンバーグ オムライス 中華料理 カレーライス 焼肉)

  def do(message_event)
    word = (rand(20) == 0) ? "白いお皿" : "飯テロ #{FOOD_WORDS.sample}"
    http = HTTP.get("https://www.googleapis.com/customsearch/v1", params: {key: ENV['DISCORD_BOT_GOOGLE_API_KEY'], cx: ENV['DISCORD_BOT_GOOGLE_API_CX'], q: word, num: 1, start: rand(10)+1, searchType: "image"})
    if http.status != 200
      message_event.send_message(I18n.t('food_porn.error'))
      return
    end
    response = JSON.parse(http.body)
    photo_source = response['items'].sample
    path = "tmp/cache/image.jpg"
    OpenURI.open_uri(photo_source["link"]) { |image|
      File.open(path, "wb") do |file| file.puts image.read; end
    }
    message_event.send_file(File.open(path, "r"))
    File.delete(path)
  end
end
