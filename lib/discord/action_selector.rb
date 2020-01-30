module ActionSelector
  extend self

  def get_message(message_event, bot)
    if Helper.pm?(message_event) || Helper.recruitment?(message_event)
      if match_keywords(message_event, Settings::SHOW_RECRUITMENT)
        return RecruitmentController::show(message_event)
      end
    end

    if Helper.recruitment?(message_event)
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
      elsif match_keywords(message_event, Settings::HELP_RESPONSE)
        return HelpController.recruitment_help(message_event)
      end
    end

    if Helper.play?(message_event)
      if match_keywords(message_event, Settings::FOOD_RESPONSE)
        return FoodPornController.do(message_event)
      elsif match_keywords(message_event, Settings::WEATHER_RESPONSE)
        return WeatherController.do(message_event)
      elsif match_keywords(message_event, Settings::FORTUNE_RESPONSE)
        return FortuneController.do(message_event)
      elsif match_keywords(message_event, Settings::NICKNAME_RESPONSE)
        return NicknameController.do(message_event)
      elsif match_keywords(message_event, Settings::WEAPON_RESPONSE)
        return WeaponController.do(message_event)
      elsif match_keywords(message_event, Settings::LUCKY_COLOR_RESPONSE)
        return LuckyColorController.do(message_event)
      elsif match_keywords(message_event, Settings::BATTLE_POWER_RESPONSE)
        return BattlePowerController.do(message_event)
      elsif match_keywords(message_event, Settings::TALK_REGEXP)
        return TalkController.do(message_event)
      end
    end


    if Helper.pm?(message_event)
      if message_event.content =~ /\A\/talk/
        return Helper.send_message_command(message_event, bot)
      elsif match_keywords(message_event, Settings::INSIDER_GAME_KEYWORD)
        return InsiderGameController.do(message_event, bot)
      end
    end

    if Helper.play?(message_event)
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
    Helper.to_safe(Helper.get_message_content(message_event)) =~ keywords
  end
end
