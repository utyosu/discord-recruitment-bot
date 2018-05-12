require_relative 'api'
module TalkController
  extend self

  TALK_REGEXP = /\A#{ENV['DISCORD_BOT_TALK_WORD']}、(.+)/

  def talk(message_event)
    return if !check_limit(message_event, "play", ENV['DISCORD_BOT_PLAY_LIMIT'] || 10)
    query = message_event.content.match(TALK_REGEXP)[1]
    response = HTTP.post("https://api.a3rt.recruit-tech.co.jp/talk/v1/smalltalk", form: {apikey: ENV['DISCORD_BOT_TALK_APIKEY'], query: query})
    return if response.status != 200
    fields = JSON.parse(response.body)
    if fields["status"] != 0
      message_event.send_message("よく分かりません")
    else
      message_event.send_message(fields["results"].first["reply"])
    end
  end
end
