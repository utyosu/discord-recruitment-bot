class RecruitmentShowAction < RecruitmentBase
  def priority
    return 1
  end

  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(Settings.keyword.recruitment.show)
  end

  # respondable is MessageEvent or Channel object
  def execute(respondable)
    show(respondable)
  end
end
