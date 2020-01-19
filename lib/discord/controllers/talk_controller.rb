module TalkController
  extend self

  def talk(message_event)
    Activity.add(message_event.author, :talk)

    query = message_event.content.match(Settings::TALK_REGEXP)[1..-1].join
    response = HTTP.post("https://api.a3rt.recruit-tech.co.jp/talk/v1/smalltalk", form: {apikey: ENV['DISCORD_BOT_TALK_APIKEY'], query: query})
    return if response.status != 200
    fields = JSON.parse(response.body)
    if fields["status"] != 0
      message_event.send_message(I18n.t('talk.error'))
    else
      message_event.send_message(fields["results"].first["reply"])
    end
  end
end
