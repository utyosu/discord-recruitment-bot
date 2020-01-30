module FortuneController
  extend self

  def do(message_event)
    Activity.add(message_event.author, :fortune)

    message_event.send_message("#{message_event.author.display_name} : #{I18n.t('fortune.prefixes').sample}#{I18n.t('fortune.words').sample}")
  end
end
