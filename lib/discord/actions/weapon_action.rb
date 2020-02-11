class WeaponAction
  def execute?(message_event)
    message_event.play? && message_event.match_any_keywords?(Settings.keyword.weapon)
  end

  def execute(message_event)
    Activity.add(message_event.author, :weapon)

    message_event.send_message(I18n.t('weapon.display', name: message_event.author.display_name, weapon: Settings.weapon.weapons.sample))
  end
end
