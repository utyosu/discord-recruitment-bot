module LuckyColorController
  module_function

  def do(message_event)
    Activity.add(message_event.author, :lucky_color)

    color_japanese, color_english = Settings.lucky_color.color.sample.split
    http = HTTP.get(
      "https://www.googleapis.com/customsearch/v1",
      params: {
        key: Settings.secret.google_search_api.key,
        cx: Settings.secret.google_search_api.cx,
        q: "#{Settings.lucky_color.words.sample}",
        num: 1,
        start: rand(10) + 1,
        searchType: "image",
        imgDominantColor: color_english,
      },
    )
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
end
