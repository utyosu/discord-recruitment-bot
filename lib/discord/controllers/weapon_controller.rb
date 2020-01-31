module WeaponController
  extend self

  def do(message_event)
    Activity.add(message_event.author, :weapon)

    message_event.send_message(I18n.t('weapon.display', name: message_event.author.display_name, weapon: Settings.weapon.weapons.sample))
  end
end
