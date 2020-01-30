module InsiderGameController
  extend self

  class InsiderGameError < StandardError; end

  def do(message_event, bot)
    Activity.add(message_event.author, :insider_game)

    command, subject = message_event.content.split(/[[:blank:]]/, 2)
    author = message_event.author
    voice_channel = get_voice_channel(author, bot)
    raise InsiderGameError.new(I18n.t('insider_game.error_no_voice_channel')) if voice_channel.blank?
    users = voice_channel.users
    insider = decide_insider(users, author)
    raise InsiderGameError.new(I18n.t('insider_game.error_no_insider')) if insider.blank?

    users.each do |user|
      if user.id == insider.id
        user.pm(I18n.t('insider_game.insider', subject: subject))
      elsif user.id == author.id
        user.pm(I18n.t('insider_game.master', subject: subject))
      else
        user.pm(I18n.t('insider_game.common'))
      end
    end
  rescue InsiderGameError => e
    author.pm(e.message)
  end

  private

  def get_voice_channel(author, bot)
    bot.servers.map{ |server_id, server|
      server.voice_channels.find{ |voice_channel|
        voice_channel.users.any?{ |user|
          user.id == author.id
        }
      }
    }.flatten.first
  end

  def decide_insider(users, author)
    users.reject{ |user| user.id == author.id }.sample
  end
end
