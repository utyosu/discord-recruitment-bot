module FortuneController
  extend self

  def do(message_event)
    Activity.add(message_event.author, :fortune)

    message_event.send_message("#{message_event.author.display_name} : #{Settings.fortune.prefixes.sample}#{Settings.fortune.words.sample}")
  end
end
