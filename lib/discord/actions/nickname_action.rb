class NicknameAction
  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.nickname)
  end

  def execute(message_event)
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
