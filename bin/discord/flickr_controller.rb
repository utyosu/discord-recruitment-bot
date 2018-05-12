require 'open-uri'

module FlickrController
  extend self
  FOOD_WORDS = %w(chicken ramen udon pasta steak grilledmeat hamburger cake pancake sushi pizza friedrice riceball tempura donut)

  def put_food_image(message_event)
    return if !check_limit(message_event, "play", ENV['DISCORD_BOT_PLAY_LIMIT'] || 10)
    http = HTTP.get("https://api.flickr.com/services/rest", params: {api_key: ENV['DISCORD_BOT_FLICKR_API_KEY'], method: "flickr.photos.search", text: "food #{FOOD_WORDS.sample}", license: "1,2,3,4,5,6", per_page: "20", format: "json", nojsoncallback: "1", privacy_filter: "1", content_type: "1", extras: "url_h,date_taken", sort: "relevance"})
    response = JSON.parse(http.body)
    if response['stat'] == "fail"
      message_event.send_message("サーバからエラー応答がありました。時間をおいても改善しない場合は管理者にご連絡下さい。")
      return
    end
    photo_source = response['photos']['photo'].sample
    path = "tmp/cache/image.jpg"
    OpenURI.open_uri("https://farm#{photo_source['farm']}.staticflickr.com/#{photo_source['server']}/#{photo_source['id']}_#{photo_source['secret']}.jpg") { |image|
      File.open(path, "wb") do |file| file.puts image.read; end
    }
    message_event.send_file(File.open(path, "r"))
    File.delete(path)
  end
end
