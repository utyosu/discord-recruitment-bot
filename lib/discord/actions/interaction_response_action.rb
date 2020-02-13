class InteractionResponseAction
  def priority
    return -2
  end

  def execute?(message_event)
    message_event.play?
  end

  def execute(message_event)
    keyword = Helper.get_message_content(message_event)
    interaction = Interaction.all.select { |i| keyword =~ /#{i.keyword}/ }.sample
    return if interaction.blank?
    Activity.add(message_event.author, :interaction_response)
    message_event.send_message(interaction.response)
  end
end