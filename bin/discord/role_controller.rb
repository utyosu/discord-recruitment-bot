module RoleController
  extend self

  def set(message_event, role_name)
    role = $bot.servers.map{|server_id, server| server.roles.find{|role| role.name == role_name}}.flatten.first
    if role.present? && !message_event.author.role?(role)
      message_event.author.add_role(role)
      message_event.send_message("#{message_event.author.display_name}さんが#{role_name}に入園しました。")
    end
  end

  def unset(message_event, role_name)
    role = $bot.servers.map{|server_id, server| server.roles.find{|role| role.name == role_name}}.flatten.first
    if role.present? && message_event.author.role?(role)
      message_event.author.remove_role(role)
      message_event.send_message("#{message_event.author.display_name}さんが#{role_name}から退園しました。")
    end
  end
end
