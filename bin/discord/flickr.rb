require 'open-uri'

module Flickr
  extend self
  FOOD_WORDS = %w(chicken ramen udon pasta steak grilledmeat hamburger cake pancake sushi pizza friedrice riceball tempura donut)

  def put_food_image(message_event)
    http = HTTP.get("https://api.flickr.com/services/rest", params: {api_key: "86cfcc185aab427ceaadd93bfc00cc9e", method: "flickr.photos.search", text: "food #{FOOD_WORDS.sample}", license: "1,2,3,4,5,6", per_page: "20", format: "json", nojsoncallback: "1", privacy_filter: "1", content_type: "1", extras: "url_h,date_taken", sort: "relevance"})
    photo_source = JSON.parse(http.body)['photos']['photo'].sample
    path = "tmp/cache/image.jpg"
    OpenURI.open_uri("https://farm#{photo_source['farm']}.staticflickr.com/#{photo_source['server']}/#{photo_source['id']}_#{photo_source['secret']}.jpg") { |image|
      File.open(path, "wb") do |file| file.puts image.read; end
    }
    message_event.send_file(File.open(path, "r"))
    File.delete(path)
  end
end
