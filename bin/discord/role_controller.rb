module RoleController
  extend self

  def set(message_event, role_name)
    user = $bot.servers.map{|server_id, server| server.members.find{|member|member.id == message_event.author.id}}.flatten.first
    role = $bot.servers.map{|server_id, server| server.roles.find{|role| role.name == role_name}}.flatten.first
    if role.present? && !user.role?(role)
      user.add_role(role)
      message_event.send_message("#{user.display_name}さんが#{role_name}に入園しました。")
      $nickname_channel.send_message("#{user.display_name}さんが#{role_name}に入園しました。\n「使い方」と発言するとロボちょすで遊ぶ方法が表示されます。")
    end
  end

  def unset(message_event, role_name)
    user = $bot.servers.map{|server_id, server| server.members.find{|member|member.id == message_event.author.id}}.flatten.first
    role = $bot.servers.map{|server_id, server| server.roles.find{|role| role.name == role_name}}.flatten.first
    if role.present? && user.role?(role)
      user.remove_role(role)
      message_event.send_message("#{user.display_name}さんが#{role_name}から退園しました。")
    end
  end
end
