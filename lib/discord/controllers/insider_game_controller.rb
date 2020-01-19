module InsiderGameController
  extend self

  def insider_game(message_event)
    Activity.add(message_event.author, :insider_game)

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
      author.pm(I18n.t('insider_game.error_no_voice_channel'))
      return
    end

    users = voice_channel.users
    insider = users.reject{|user| user.id == author.id}.sample

    if insider.blank?
      author.pm(I18n.t('insider_game.error_no_insider'))
      return
    end

    users.each do |user|
      if user.id == insider.id
        user.pm(I18n.t('insider_game.insider', subject: subject))
      elsif user.id == author.id
        user.pm(I18n.t('insider_game.master', subject: subject))
      else
        user.pm(I18n.t('insider_game.common'))
      end
    end
  end
end
