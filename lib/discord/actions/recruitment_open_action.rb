class RecruitmentOpenAction < RecruitmentBase
  def priority
    return 1
  end

  def execute?(message_event)
    message_event.recruitment? && message_event.match_any_keywords?(['@\d+'])
  end

  def execute(message_event)
    user = User.get_by_discord_user(message_event.author)
    # できるだけ原文を維持したいのでExtractor.formatは実行せずに改行の削除のみ行う
    recruit_message = message_event.content.gsub(/\R/, "")
    recruitment = Recruitment.create(content: recruit_message)
    recruitment.join(user)
    if recruitment.reserve_at.present?
      message_event.send_message(
        I18n.t(
          "recruitment.open_reserved",
          name: user.name,
          label_id: recruitment.label_id,
          time: recruitment.reserve_at.to_simply,
        )
      )
    else
      message_event.send_message(
        I18n.t(
          "recruitment.open_standard",
          name: user.name,
          label_id: recruitment.label_id,
          time: (recruitment.created_at + Settings.recruitment.expire_sec).to_simply
        )
      )
    end
    show(message_event)
    TwitterController.new.recruitment_open(recruitment)
  end
end
