module HelpController
  module_function

  def recruitment_help(message_event)
    message_event.send_message(I18n.t('help.recruitment'))
  end
end
