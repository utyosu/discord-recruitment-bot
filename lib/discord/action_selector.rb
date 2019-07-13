module ActionSelector
  extend self

  def get_message(message_event)
    begin
      if message_event.channel.type == 1 || $recruitment_channel == message_event.channel
        if match_keywords(message_event, Keywords::SHOW_RECRUITMENT)
          return RecruitmentController::show(message_event.channel)
        end
      end

      if $recruitment_channel == message_event.channel
        if match_keywords(message_event, Keywords::OPEN_RECRUITMENT)
          return RecruitmentController::open(message_event)
        elsif match_keywords(message_event, Keywords::CLOSE_RECRUITMENT)
          return RecruitmentController::close(message_event)
        elsif match_keywords(message_event, Keywords::JOIN_RECRUITMENT)
          return RecruitmentController::join(message_event)
        elsif match_keywords(message_event, Keywords::LEAVE_RECRUITMENT)
          return RecruitmentController::leave(message_event)
        elsif match_keywords(message_event, Keywords::RESURRECTION_RECRUITMENT)
          return RecruitmentController::resurrection(message_event)
        end
      end

      if $play_channel == message_event.channel
        if match_keywords(message_event, Keywords::FOOD_RESPONSE)
          return FoodPornController.do(message_event)
        elsif match_keywords(message_event, Keywords::WEATHER_RESPONSE)
          return WeatherController.get(message_event)
        elsif match_keywords(message_event, Keywords::FORTUNE_RESPONSE)
          return FortuneController.get(message_event)
        elsif match_keywords(message_event, Keywords::NICKNAME_RESPONSE)
          return NicknameController.do(message_event)
        elsif match_keywords(message_event, TalkController::TALK_REGEXP)
          return TalkController.talk(message_event)
        elsif match_keywords(message_event, Keywords::WEAPON_RESPONSE)
          return WeaponController.do(message_event)
        elsif match_keywords(message_event, Keywords::LUCKY_COLOR_RESPONSE)
          return LuckyColorController.do(message_event)
        elsif match_keywords(message_event, Keywords::BATTLE_POWER_RESPONSE)
          return BattlePowerController.do(message_event)
        end
      end

      if match_keywords(message_event, Keywords::HELP_RESPONSE)
        return HelpController.help(message_event)
      end

      # only private channel
      if message_event.channel.type == 1
        if message_event.content =~ /\A\/talk/
          return send_message_command(message_event)
        elsif message_event.content =~ /\Aインサイダーゲーム/
          return InsiderGameController::insider_game(message_event)
        end
      end

      if $play_channel == message_event.channel
        if match_keywords(message_event, Keywords::INTERACTION_CREATE)
          return InteractionController::interaction_create(message_event)
        elsif match_keywords(message_event, Keywords::INTERACTION_DESTROY)
          return InteractionController::interaction_destroy(message_event)
        elsif match_keywords(message_event, Keywords::INTERACTION_RESPONSE)
          return InteractionController::interaction_list(message_event)
        end
        return InteractionController::interaction_response(message_event)
      end

    rescue HTTP::ConnectionError => e
      message_event.send_message("サーバへのアクセスに失敗しました。時間をおいても改善しない場合は管理者にご連絡下さい。")
    rescue Api::InvalidStatusError => e
      message_event.send_message(e.message)
    end
  end

  private

  def match_keywords(message_event, keywords)
    to_safe(get_message_content(message_event)) =~ keywords
  end
end
