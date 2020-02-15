class RecruitmentLeaveAction < RecruitmentBase
  def priority
    return 1
  end

  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(Settings.keyword.recruitment.leave)
  end

  def execute(message_event)
    recruitment = get_recruitment_by_message_event(message_event)
    user = User.get_by_discord_user(message_event.author)
    return if recruitment.blank? || !recruitment.attended?(user)
    TwitterController.new.recruitment_leave(recruitment)
    message_event.send_message(I18n.t("recruitment.cancel", name: user.name, label_id: recruitment.label_id))
    recruitment.leave(user)
    show(message_event)
  end
end
