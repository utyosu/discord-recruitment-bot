class FoodPornAction
  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.food_porn)
  end

  def execute(message_event)
    Activity.add(message_event.author, :food_porn)

    word =
      if rand(8192) == 0
        Settings.food_porn.rare_word.sample
      else
        "#{Settings.food_porn.base_word} #{Settings.food_porn.words.sample}"
      end

    http = HTTP.get(
      "https://www.googleapis.com/customsearch/v1",
      params: {
        key: Settings.secret.google_search_api.key,
        cx: Settings.secret.google_search_api.cx,
        q: word,
        num: 1,
        start: rand(1..10),
        searchType: "image",
      },
    )
    if http.status != 200
      message_event.send_message(I18n.t('food_porn.error'))
      return
    end
    response = JSON.parse(http.body)
    photo_source = response['items'].sample
    path = "tmp/cache/image.jpg"
    OpenURI.open_uri(photo_source["link"]) do |image|
      File.open(path, "wb") { |file| file.puts image.read }
    end
    message_event.send_file(File.open(path, "r"))
    File.delete(path)
  end
end
