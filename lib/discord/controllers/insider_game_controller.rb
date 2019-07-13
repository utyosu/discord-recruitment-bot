module InsiderGameController
  extend self

  def insider_game(message_event)
    command, subject = message_event.content.split(/[[:blank:]]/, 2)
    author = message_event.author
    voice_channel = $bot.servers.map{ |server_id, server|
      server.voice_channels.find{ |voice_channel|
        voice_channel.users.any?{ |user|
          user.id == author.id
        }
      }
    }.flatten.first

    if voice_channel.blank?
      author.pm("インサイダーゲームを遊ぶにはボイスチャンネルに接続して下さい。")
      return
    end

    users = voice_channel.users
    insider = users.reject{|user| user.id == author.id}.sample

    if insider.blank?
      author.pm("インサイダーがいません。")
      return
    end

    users.each do |user|
      if user.id == insider.id
        user.pm("[インサイダーゲーム] あなたは「インサイダー」です。お題は「#{subject}」です。")
      elsif user.id == author.id
        user.pm("[インサイダーゲーム] あなたは「マスター」です。お題は「#{subject}」です。")
      else
        user.pm("[インサイダーゲーム] あなたは「庶民」です。お題は分かりません。")
      end
    end
  end
end
