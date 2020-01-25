module ActionSelector
  extend self

  def get_message(message_event)
    if message_event.channel.type == 1 || $recruitment_channel == message_event.channel
      if match_keywords(message_event, Settings::SHOW_RECRUITMENT)
        return RecruitmentController::show(message_event.channel)
      end
    end

    if $recruitment_channel == message_event.channel
      if match_keywords(message_event, Settings::OPEN_RECRUITMENT)
        return RecruitmentController::open(message_event)
      elsif match_keywords(message_event, Settings::CLOSE_RECRUITMENT)
        return RecruitmentController::close(message_event)
      elsif match_keywords(message_event, Settings::JOIN_RECRUITMENT)
        return RecruitmentController::join(message_event)
      elsif match_keywords(message_event, Settings::LEAVE_RECRUITMENT)
        return RecruitmentController::leave(message_event)
      elsif match_keywords(message_event, Settings::RESURRECTION_RECRUITMENT)
        return RecruitmentController::resurrection(message_event)
      end
    end

    if $play_channel == message_event.channel
      if match_keywords(message_event, Settings::FOOD_RESPONSE)
        return FoodPornController.do(message_event)
      elsif match_keywords(message_event, Settings::WEATHER_RESPONSE)
        return WeatherController.get(message_event)
      elsif match_keywords(message_event, Settings::FORTUNE_RESPONSE)
        return FortuneController.get(message_event)
      elsif match_keywords(message_event, Settings::NICKNAME_RESPONSE)
        return NicknameController.do(message_event)
      elsif match_keywords(message_event, Settings::TALK_REGEXP)
        return TalkController.talk(message_event)
      elsif match_keywords(message_event, Settings::WEAPON_RESPONSE)
        return WeaponController.do(message_event)
      elsif match_keywords(message_event, Settings::LUCKY_COLOR_RESPONSE)
        return LuckyColorController.do(message_event)
      elsif match_keywords(message_event, Settings::BATTLE_POWER_RESPONSE)
        return BattlePowerController.do(message_event)
      end
    end

    if match_keywords(message_event, Settings::HELP_RESPONSE)
      return HelpController.help(message_event)
    end

    # only private channel
    if message_event.channel.type == 1
      if message_event.content =~ /\A\/talk/
        return send_message_command(message_event)
      elsif match_keywords(message_event, Settings::INSIDER_GAME_KEYWORD)
        return InsiderGameController::insider_game(message_event)
      end
    end

    if $play_channel == message_event.channel
      if match_keywords(message_event, Settings::INTERACTION_CREATE)
        return InteractionController::create(message_event)
      elsif match_keywords(message_event, Settings::INTERACTION_DESTROY)
        return InteractionController::destroy(message_event)
      end
      return InteractionController::response(message_event)
    end
  end

  private

  def match_keywords(message_event, keywords)
    to_safe(get_message_content(message_event)) =~ keywords
  end
end
