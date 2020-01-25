module NicknameController
  extend self

  def do(message_event)
    Activity.add(message_event.author, :nickname)

    nick = message_event.author.display_name.dup
    nick = "#{I18n.t('nickname.prefixes').sample}#{nick}#{I18n.t('nickname.suffixes').sample}"
    if rand(6) == 0
      decoration = I18n.t('nickname.decorations').sample
      nick = "#{decoration}#{nick}#{decoration}"
    end
    message_event.send_message(I18n.t('nickname.display', name: message_event.author.display_name, nick: nick))
  end
end
