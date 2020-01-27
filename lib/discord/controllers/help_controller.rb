module HelpController
  extend self

  def help(message_event)
    if recruitment?(message_event)
      message_event.send_message(I18n.t('help.recruitment'))
    end
  end
end
