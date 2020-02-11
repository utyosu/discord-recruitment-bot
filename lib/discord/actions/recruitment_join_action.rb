class RecruitmentJoinAction < RecruitmentBase
  def priority
    return 1
  end

  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(Settings.keyword.recruitment.join)
  end

  def execute(message_event)
    recruitment = get_recruitment_by_message_event(message_event)
    user = User.get_by_discord_user(message_event.author)
    return if recruitment.blank? || recruitment.attended?(user)

    recruitment.join(user)
    message_event.send_message(I18n.t('recruitment.join', name: user.name, label_id: recruitment.label_id))
    show(message_event)
    TwitterController.new.recruitment_join(recruitment)

    return unless recruitment.full?
    if recruitment.reserve_at.present? && recruitment.reserve_at.in_time_zone > Time.zone.now
      message_event.send_message(I18n.t('recruitment.reserve_full', time: recruitment.reserve_at.to_simply))
    else
      recruitment.update(enable: false)
      message_event.send_message("#{recruitment.mentions}\n#{I18n.t('recruitment.one_time_notification')}")
      message_event.send_message(I18n.t("recruitment.one_time_close", label_id: recruitment.label_id))
      show(message_event)
      TwitterController.new.recruitment_close(recruitment)
    end
  end
end
