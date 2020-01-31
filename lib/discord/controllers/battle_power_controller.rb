module BattlePowerController
  extend self

  def do(message_event)
    Activity.add(message_event.author, :battle_power)

    battle_power, character = Settings.battle_power.content.sample.split
    message_event.send_message(I18n.t('battle_power.display', name: message_event.author.display_name, battle_power: battle_power, character: character))
  end
end
