module NicknameController
  module_function

  def do(message_event)
    Activity.add(message_event.author, :nickname)

    nick = message_event.author.display_name.dup
    nick = "#{Settings.nickname.prefixes.sample}#{nick}#{Settings.nickname.suffixes.sample}"
    if rand(6) == 0
      decoration = Settings.nickname.decorations.sample
      nick = "#{decoration}#{nick}#{decoration}"
    end
    message_event.send_message(I18n.t('nickname.display', name: message_event.author.display_name, nick: nick))
  end
end
