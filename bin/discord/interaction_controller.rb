module InteractionController
  extend self

  def interaction_create(message_event)
    src = get_message_content(message_event).gsub(/\p{blank}/," ").split
    return if src.size != 3 || src[1].size < 2 || src[2].size < 1 || 64 < src[1].size || 64 < src[2].size
    interaction = JSON.parse(Api::Interaction.create(keyword: src[1], response: src[2],registered_user_name:  message_event.author.username, registered_user_discord_id: message_event.author.id).body)
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
    message_event.send_message(interaction['response']) if interaction['response'].present?
  end
end