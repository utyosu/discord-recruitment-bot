module RecruitmentController
  extend self

  RESERVE_OVER_TIME = 30

  def show(channel)
    channel.send_message("```\n#{recruitments_message}\n```")
  end

  def destroy_expired_recruitment
    recruitments = JSON.parse(Api::Recruitment.index.body)
    destroyed_recruitments = []
    recruitments.each do |recruitment|
      if recruitment['reserve_at'].present?
        if recruitment['reserve_at'].in_time_zone < Time.zone.now - (60 * RESERVE_OVER_TIME)
          reserve_recruitment_over_time(recruitment)
        elsif recruitment['reserve_at'].in_time_zone < Time.zone.now
          reserve_recruitment_on_time(recruitment)
        end
      else
        if (recruitment['created_at'].in_time_zone + EXPIRE_TIME) < Time.zone.now
          temporary_recruitment_expired(recruitment)
        end
      end
    end
  end

  def format_recruitment_to_string(recruitment)
    recruitment_message = "[#{recruitment['label_id']}] #{recruitment['content']} by #{recruitment['participants'].first['name']} (#{recruitment['participants'].size-1}/#{extraction_recruit_user_count(recruitment['content'])})"
    if 2 <= recruitment['participants'].size
      recruitment_message += "\n    参加者: #{recruitment['participants'][1..-1].map{|p|p['name']}.join(', ')}"
    end
    return recruitment_message
  end

  def open(message_event)
    recruit_message = get_message_content(message_event)
    recruitment = JSON.parse(Api::Recruitment.create(content: recruit_message, reserve_at: extraction_time(recruit_message).to_s).body)
    Api::Participant.join(recruitment, name: message_event.author.display_name, discord_id: message_event.author.id)
    if recruitment['reserve_at'].present?
      message_event.send_message("#{message_event.author.display_name}さんから [#{recruitment['label_id']}] を予定時間 #{view_datetime(recruitment['reserve_at'])} で受け付けました。")
    else
      message_event.send_message("#{message_event.author.display_name}さんから [#{recruitment['label_id']}] を期限 #{view_datetime(recruitment['created_at'].in_time_zone + EXPIRE_TIME)} で受け付けました。")
    end
    self.show(message_event.channel)
    TwitterController.recruitment_open(recruitment)
  end

  def close(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    my_discord_id = message_event.author.id.to_s
    closed_recruitments = []
    JSON.parse(Api::Recruitment.index.body).each do |recruitment, recruitment_index|
      if number == recruitment['label_id']
        Api::Recruitment.destroy(recruitment)
        message_event.send_message("#{message_event.author.display_name}さんが [#{recruitment['label_id']}] を終了しました。")
        self.show(message_event.channel)
        TwitterController.recruitment_close(recruitment)
        return
      end
    end
  end

  def join(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    recruitments = JSON.parse(Api::Recruitment.index.body)
    recruitments.each do |recruitment|
      if number == recruitment['label_id'] && !recruitment['participants'].any?{|p|p['discord_id'] == message_event.author.id.to_s}
        Api::Participant.join(recruitment, name: message_event.author.display_name, discord_id: message_event.author.id)
        message_event.send_message("#{message_event.author.display_name}さんが [#{recruitment['label_id']}] に参加しました。")
        self.show(message_event.channel)
        TwitterController.recruitment_join(recruitment)
        if recruitment['participants'].size >= extraction_recruit_user_count(recruitment['content'])
          if recruitment['reserve_at'].present? && recruitment['reserve_at'].in_time_zone > Time.zone.now
            message_event.send_message("メンバーが集まりました。\n#{view_datetime(recruitment['reserve_at'])} になったら連絡するね(・∀・)b")
          else
            recruitment = update_recruitment(recruitment)
            Api::Recruitment.destroy(recruitment)
            mention = build_mention_from_participants(recruitment['participants'])
            message_event.send_message("#{mention}\nメンバーが集まりました。(｀・ω・´)ﾔｯﾀﾈ")
            message_event.send_message("[#{recruitment['label_id']}] を終了しました。")
            self.show(message_event.channel)
            TwitterController.recruitment_close(recruitment)
          end
        end
        return
      end
    end
  end

  def leave(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    my_discord_id = message_event.author.id.to_s
    JSON.parse(Api::Recruitment.index.body).each do |recruitment|
      next if number != recruitment['label_id']
      recruitment['participants'].each do |participant|
        if participant['discord_id'] == my_discord_id
          Api::Participant.leave(recruitment, participant)
          message_event.send_message("#{message_event.author.display_name}さんが [#{recruitment['label_id']}] の参加をキャンセルしました。")
          self.show(message_event.channel)
          TwitterController.recruitment_leave(recruitment)
          return
        end
      end
    end
  end

  def resurrection(message_event)
    recruitment = JSON.parse(Api::Recruitment.resurrection.body)
    message_event.send_message("#{message_event.author.display_name}さんが [#{recruitment['label_id']}] を復活させました。")
    self.show(message_event.channel)
    return
  end

  private

  def recruitments_message
    recruitments = JSON.parse(Api::Recruitment.index.body)
    return "募集はありません" if recruitments.blank?
    recruitment_message = recruitments.sort_by{|recruitment|
      recruitment['label_id']
    }.map{|recruitment|
      format_recruitment_to_string(recruitment)
    }.join("\n")
    return recruitment_message
  end

  def reserve_recruitment_on_time(recruitment)
    if extraction_recruit_user_count(recruitment['content']) <= (recruitment['participants'].size-1)
      Api::Recruitment.destroy(recruitment)
      mention = build_mention_from_participants(recruitment['participants'])
      $recruitment_channel.send_message("#{mention}\n[#{recruitment['label_id']}] の予定時間です。(*´∀`)ﾉ ｲﾃﾗｰ")
      $recruitment_channel.send_message("```\n#{format_recruitment_to_string(recruitment)}\n```")
      $recruitment_channel.send_message("[#{recruitment['label_id']}] は予定時間になったので終了します。")
      self.show($recruitment_channel)
      TwitterController.recruitment_close(recruitment)
    elsif !recruitment['notificated']
      Api::Recruitment.update(recruitment, {notificated: true})
      $recruitment_channel.send_message("[#{recruitment['label_id']}] の開始時間になりました。あと#{extraction_recruit_user_count(recruitment['content']) - (recruitment['participants'].size-1)}人ｲﾅｲｶﾅ?(o・ω・)")
      self.show($recruitment_channel)
    end
  end

  def reserve_recruitment_over_time(recruitment)
    Api::Recruitment.destroy(recruitment)
    $recruitment_channel.send_message("[#{recruitment['label_id']}] は開始時間を#{RESERVE_OVER_TIME}分過ぎたので終了します。")
    self.show($recruitment_channel)
    TwitterController.recruitment_close(recruitment)
  end

  def temporary_recruitment_expired(recruitment)
    Api::Recruitment.destroy(recruitment)
    $recruitment_channel.send_message("[#{recruitment['label_id']}] は期限を過ぎたので終了します。")
    self.show($recruitment_channel)
    TwitterController.recruitment_close(recruitment)
  end
end
