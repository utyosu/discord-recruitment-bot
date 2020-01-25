module HelpController
  extend self

  def help(message_event)
    if $recruitment_channel == message_event.channel
      message_event.send_message(I18n.t('help.recruitment'))
    end
  end
end
