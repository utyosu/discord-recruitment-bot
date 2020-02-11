class RecruitmentBase
  # respondable is MessageEvent or Channel object
  def show(respondable)
    Recruitment.clean_invalid
    respondable.send_message("```\n#{recruitments_message}\n```")
  end

  def destroy_expired_recruitment(recruitment_channel)
    Recruitment.active.each do |recruitment|
      if recruitment.reserve_at.present?
        if recruitment.reserve_at < Time.zone.now - Settings.recruitment.reserve_over_sec
          reserve_recruitment_over_time(recruitment, recruitment_channel)
        elsif recruitment.reserve_at < Time.zone.now
          reserve_recruitment_on_time(recruitment, recruitment_channel)
        end
      elsif (recruitment.created_at + Settings.recruitment.expire_sec) < Time.zone.now
        temporary_recruitment_expired(recruitment, recruitment_channel)
      end
    end
  end

  private

  def get_recruitment_by_message_event(message_event)
    label_id = Extractor.extraction_number(Helper.get_message_content(message_event))
    if label_id.nil?
      message_event.send_message(I18n.t('recruitment.error_two_numbers'))
      return nil
    end
    return Recruitment.get_by_label_id(label_id)
  end

  def recruitments_message
    recruitments = Recruitment.active
    return I18n.t('recruitment.not_found') if recruitments.blank?
    recruitment_message =
      recruitments
      .sort_by(&:label_id)
      .map(&:to_format_string)
      .join("\n")
    return recruitment_message
  end

  def reserve_recruitment_on_time(recruitment, recruitment_channel)
    if recruitment.capacity <= recruitment.reserved
      recruitment.update(enable: false)
      mention = recruitment.mentions
      recruitment_channel.send_message("#{mention}\n#{I18n.t('recruitment.reserve_notification', label_id: recruitment.label_id)}")
      recruitment_channel.send_message("```\n#{recruitment.to_format_string}\n```")
      recruitment_channel.send_message(I18n.t('recruitment.reserve_close', label_id: recruitment.label_id))
      show(recruitment_channel)
      TwitterController.new.recruitment_close(recruitment)
    elsif !recruitment.notificated
      recruitment.update(notificated: true)
      recruitment_channel.send_message(I18n.t('recruitment.reserve_on_time', label_id: recruitment.label_id, vacant: recruitment.vacant))
      show(recruitment_channel)
    end
  end

  def reserve_recruitment_over_time(recruitment, recruitment_channel)
    recruitment.update(enable: false)
    recruitment_channel.send_message(I18n.t('recruitment.one_time_over', label_id: recruitment.label_id, time: Settings.recruitment.reserve_over_sec / 60))
    show(recruitment_channel)
    TwitterController.new.recruitment_close(recruitment)
  end

  def temporary_recruitment_expired(recruitment, recruitment_channel)
    recruitment.update(enable: false)
    recruitment_channel.send_message(I18n.t('recruitment.reserve_over', label_id: recruitment.label_id))
    show(recruitment_channel)
    TwitterController.new.recruitment_close(recruitment)
  end
end
