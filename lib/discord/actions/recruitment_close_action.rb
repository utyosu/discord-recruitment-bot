class RecruitmentCloseAction < RecruitmentBase
  def priority
    return 1
  end

  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(Settings.keyword.recruitment.close)
  end

  def execute(message_event)
    recruitment = get_recruitment_by_message_event(message_event)
    return if recruitment.blank?
    user = User.get_by_discord_user(message_event.author)

    recruitment.update(enable: false)
    message_event.send_message(I18n.t("recruitment.close", name: user.name, label_id: recruitment.label_id))
    show(message_event)
    TwitterController.new.recruitment_close(recruitment)
  end
end
