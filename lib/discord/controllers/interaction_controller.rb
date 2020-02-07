module InteractionController
  extend self

  def create(message_event)
    Activity.add(message_event.author, :interaction_create)

    _command, keyword, response = Helper.get_message_content(message_event).gsub(/\p{blank}/, " ").split(/ /, 3)
    return if keyword.size < 1 || 64 < keyword.size || response.size < 1 || 64 < response.size
    user = User.get_by_discord_user(message_event.author)
    Interaction.create(user: user, keyword: keyword, response: response)
    message_event.send_message(I18n.t('interaction.remember', keyword: keyword, response: response))
  end

  def destroy(message_event)
    Activity.add(message_event.author, :interaction_destroy)

    _command, keyword, other = Helper.get_message_content(message_event).gsub(/\p{blank}/, " ").split
    return if keyword.blank? || other.present?
    interactions = Interaction.where(keyword: keyword)
    if interactions.present?
      interactions.destroy_all
      message_event.send_message(I18n.t('interaction.forget', keyword: keyword))
    end
  end

  def response(message_event)
    keyword = Helper.get_message_content(message_event)
    interaction = Interaction.all.select { |i| keyword =~ /#{i.keyword}/ }.sample
    if interaction.present?
      Activity.add(message_event.author, :interaction_response)
      message_event.send_message(interaction.response)
    end
  end
end
