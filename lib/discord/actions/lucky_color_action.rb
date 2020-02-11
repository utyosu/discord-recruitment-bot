class LuckyColorAction
  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.lucky_color)
  end

  def execute(message_event)
    Activity.add(message_event.author, :lucky_color)

    color_japanese, color_english = Settings.lucky_color.color.sample.split
    http = request_to_customsearch(color_english)
    if http.status != 200
      message_event.send_message(I18n.t('lucky_color.error'))
      return
    end
    response = JSON.parse(http.body)
    photo_source = response['items'].sample
    path = "tmp/cache/image.jpg"
    OpenURI.open_uri(photo_source["link"]) do |image|
      File.open(path, "wb") { |file| file.puts image.read }
    end
    message_event.send_message(I18n.t('lucky_color.display', name: message_event.author.display_name, color: color_japanese))
    message_event.send_file(File.open(path, "r"))
    File.delete(path)
  end

  def request_to_customsearch(color_english)
    HTTP.get(
      "https://www.googleapis.com/customsearch/v1",
      params: {
        key: Settings.secret.google_search_api.key,
        cx: Settings.secret.google_search_api.cx,
        q: Settings.lucky_color.words.sample.to_s,
        num: 1,
        start: rand(1..10),
        searchType: "image",
        imgDominantColor: color_english,
      }
    )
  end
end
