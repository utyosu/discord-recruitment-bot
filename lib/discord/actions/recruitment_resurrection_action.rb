class RecruitmentResurrectionAction < RecruitmentBase
  def priority
    return 1
  end

  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(Settings.keyword.recruitment.resurrection)
  end

  def execute(message_event)
    user = User.get_by_discord_user(message_event.author)
    recruitment = Recruitment.order("updated_at DESC").where(enable: false).first
    return if recruitment.blank?
    recruitment.set_label_id
    recruitment.update(enable: true)
    message_event.send_message(I18n.t('recruitment.resurrection', name: user.name, label_id: recruitment.label_id))
    show(message_event)
  end
end
