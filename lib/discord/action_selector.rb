module ActionSelector
  extend self

  def get_message(message_event, bot)
    content = Helper.to_safe(Helper.get_message_content(message_event))

    if Helper.pm?(message_event) || Helper.recruitment?(message_event)
      if match_keywords(content, Settings.keyword.recruitment.show)
        return RecruitmentController.show(message_event)
      end
    end

    if Helper.recruitment?(message_event)
      if match_keywords(content, ['@\d+'])
        return RecruitmentController.open(message_event)
      elsif match_keywords(content, Settings.keyword.recruitment.close)
        return RecruitmentController.close(message_event)
      elsif match_keywords(content, Settings.keyword.recruitment.join)
        return RecruitmentController.join(message_event)
      elsif match_keywords(content, Settings.keyword.recruitment.leave)
        return RecruitmentController.leave(message_event)
      elsif match_keywords(content, Settings.keyword.recruitment.resurrection)
        return RecruitmentController.resurrection(message_event)
      elsif match_keywords(content, Settings.keyword.help)
        return HelpController.recruitment_help(message_event)
      end
    end

    if Helper.play?(message_event)
      if match_keywords(content, Settings.keyword.food_porn)
        return FoodPornController.do(message_event)
      elsif match_keywords(content, Settings.keyword.weather)
        return WeatherController.do(message_event)
      elsif match_keywords(content, Settings.keyword.fortune)
        return FortuneController.do(message_event)
      elsif match_keywords(content, Settings.keyword.nickname)
        return NicknameController.do(message_event)
      elsif match_keywords(content, Settings.keyword.weapon)
        return WeaponController.do(message_event)
      elsif match_keywords(content, Settings.keyword.lucky_color)
        return LuckyColorController.do(message_event)
      elsif match_keywords(content, Settings.keyword.battle_power)
        return BattlePowerController.do(message_event)
      elsif match_keywords(content, Settings.keyword.talk)
        return TalkController.do(message_event)
      end
    end

    if Helper.pm?(message_event)
      if message_event.content =~ /\A\/talk/
        return Helper.send_message_command(message_event, bot)
      elsif match_keywords(content, Settings.keyword.insider_game)
        return InsiderGameController.do(message_event, bot)
      end
    end

    if Helper.play?(message_event)
      if match_keywords(content, Settings.keyword.interaction.create)
        return InteractionController.create(message_event)
      elsif match_keywords(content, Settings.keyword.interaction.destroy)
        return InteractionController.destroy(message_event)
      end
      return InteractionController.response(message_event)
    end
  end

  private

  def match_keywords(content, keywords)
    keywords.any? { |keyword| content.match?(Regexp.new(keyword)) }
  end
end
