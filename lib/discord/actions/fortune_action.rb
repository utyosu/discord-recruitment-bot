class FortuneAction
  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.fortune)
  end

  def execute(message_event)
    Activity.add(message_event.author, :fortune)

    message_event.send_message("#{message_event.author.display_name} : #{Settings.fortune.prefixes.sample}#{Settings.fortune.words.sample}")
  end
end
