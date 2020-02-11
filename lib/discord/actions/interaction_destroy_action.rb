class InteractionDestroyAction
  def priority
    return -1
  end

  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.interaction.destroy)
  end

  def execute(message_event)
    Activity.add(message_event.author, :interaction_destroy)

    _command, keyword, other = Helper.get_message_content(message_event).gsub(/\p{blank}/, " ").split
    return if keyword.blank? || other.present?
    interactions = Interaction.where(keyword: keyword)
    return if interactions.blank?
    interactions.destroy_all
    message_event.send_message(I18n.t('interaction.forget', keyword: keyword))
  end
end
