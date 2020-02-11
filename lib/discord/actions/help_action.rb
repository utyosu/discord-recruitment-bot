class HelpAction
  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(Settings.keyword.help)
  end

  def execute(message_event)
    message_event.send_message(I18n.t('help.recruitment'))
  end
end
