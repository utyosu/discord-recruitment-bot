class InteractionCreateAction
  def priority
    return -1
  end

  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.interaction.create)
  end

  def execute(message_event)
    Activity.add(message_event.author, :interaction_create)

    _command, keyword, response = Extractor.format(message_event.content).split(/ /, 3)
    return if keyword.blank? || !(1..64).cover?(keyword.size) || response.blank? || !(1..64).cover?(response.size)
    user = User.get_by_discord_user(message_event.author)
    Interaction.create(user: user, keyword: keyword, response: response)
    message_event.send_message(I18n.t("interaction.remember", keyword: keyword, response: response))
  end
end
