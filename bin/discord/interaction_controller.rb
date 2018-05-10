module InteractionController
  extend self

  def interaction_create(message_event)
    command, keyword, response, other = get_message_content(message_event).gsub(/\p{blank}/," ").split
    return if keyword.size < 1 || 64 < keyword.size || keyword =~ $KEYWORDS_INTERACTION_RESPONSE || response.size < 1 || 64 < response.size || other.present?
    interaction = JSON.parse(Api::Interaction.create(keyword: keyword, response: response, registered_user_name:  message_event.author.display_name, registered_user_discord_id: message_event.author.id).body)
    message_event.send_message("「#{interaction['keyword']}」を「#{interaction['response']}」と覚えました。")
  end

  def interaction_destroy(message_event)
    src = get_message_content(message_event).gsub(/\p{blank}/," ").split
    return if src.size != 2 || src[1].size < 1
    response = Api::Interaction.destroy(src[1])
    message_event.send_message("「#{src[1]}」を忘れました。") if response.status == 200
  end

  def interaction_response(message_event)
    interaction = JSON.parse(Api::Interaction.search(get_message_content(message_event)).body)
    if interaction['response'].present?
      message_event.send_message(interaction['response'])
    end
  end

  def interaction_list(message_event)
    interactions = JSON.parse(Api::Interaction.index.body)
    keywords = interactions.map{|interaction| interaction['keyword']}
    message_event.send_message("記憶している単語一覧です。")
    message_event.send_message("```\n#{keywords.join(', ')}\n```")
  end
end
