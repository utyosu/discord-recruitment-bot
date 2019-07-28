module InteractionController
  extend self

  def create(message_event)
    command, keyword, response = get_message_content(message_event).gsub(/\p{blank}/," ").split(/ /, 3)
    return if keyword.size < 1 || 64 < keyword.size || keyword =~ $KEYWORDS_INTERACTION_RESPONSE || response.size < 1 || 64 < response.size
    user = User.get_by_discord_user(message_event.author)
    interaction = Interaction.create(user: user, keyword: keyword, response: response)
    message_event.send_message(I18n.t('interaction.remember', keyword: keyword, response: response))
  end

  def destroy(message_event)
    command, keyword, other = get_message_content(message_event).gsub(/\p{blank}/," ").split
    return if keyword.blank? || other.present?
    interactions = Interaction.where(keyword: keyword)
    if interactions.present?
      interactions.destroy_all
      message_event.send_message(I18n.t('interaction.forget', keyword: keyword))
    end
  end

  def response(message_event)
    keyword = get_message_content(message_event)
    interaction = Interaction.all.select { |i| keyword =~ /#{i.keyword}/ }.sample
    message_event.send_message(interaction.response) if interaction.present?
  end

  def list(message_event)
    keywords = Interaction.all.map{|interaction| interaction['keyword']}
    message_event.send_message(I18n.t('interaction.list'))
    message_event.send_message("```\n#{keywords.join(', ')}\n```")
  end
end
