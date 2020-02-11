class TalkAction
  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.talk)
  end

  def execute(message_event)
    Activity.add(message_event.author, :talk)

    query = message_event.content.gsub(/#{Settings.keyword.talk.join('|')}/, '')
    response = HTTP.post("https://api.a3rt.recruit-tech.co.jp/talk/v1/smalltalk", form: { apikey: Settings.secret.small_talk_api.key, query: query })
    return if response.status != 200
    fields = JSON.parse(response.body)
    if fields["status"] != 0
      message_event.send_message(I18n.t('talk.error'))
    else
      message_event.send_message(fields["results"].first["reply"])
    end
  end
end
