class LotteryAction
  def execute?(message_event)
    message_event.play? &&
      message_event.match_any_keywords?(Settings.keyword.lottery)
  end

  def execute(message_event)
    if Settings.lottery.limit <= lottery_count(message_event.author)
      return message_event.send_message(I18n.t("lottery.over", limit: Settings.lottery.limit))
    end

    Activity.add(message_event.author, :lottery)

    message_event.send_message(lottery_message(message_event.author.display_name))
  end

  def lottery_count(author)
    Activity.where(
      user: User.get_by_discord_user(author),
      content: :lottery,
      created_at: Time.zone.today.beginning_of_day...Time.zone.today.end_of_day
    ).count
  end

  def lottery_message(name)
    case rand(6_096_454)
    when 0..1_000 then I18n.t("lottery.rank1", name: name)
    when 0..6_000 then I18n.t("lottery.rank2", name: name)
    when 0..212_222 then I18n.t("lottery.rank3", name: name)
    when 0..922_138 then I18n.t("lottery.rank4", name: name)
    when 0..3_048_227 then I18n.t("lottery.rank5", name: name)
    else I18n.t("lottery.miss", name: name)
    end
  end
end
