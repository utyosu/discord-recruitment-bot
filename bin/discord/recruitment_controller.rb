module RecruitmentController
  extend self

  def show(message_event)
    message_event.send_message(recruitments_message)
  end

  def destroy_expired_recruitment
    recruitments = JSON.parse(Api::Recruitment.index.body)
    destroyed_recruitments = []
    recruitments.each do |recruitment|
      if recruitment['reserve_at'].present?
        if recruitment['reserve_at'].in_time_zone < Time.zone.now
          Api::Recruitment.destroy(recruitment)
          if 1 >= recruitment['participants'].size
            $target_channel.send_message("[#{recruitment['label_id']}] は予定時間になりましたが参加者が集まらなかったので終了します。(´・ω・｀)ｼｮﾎﾞｰﾝ")
            $target_channel.send_message(recruitments_message)
          else
            mention = recruitment['participants'].map{|p|"<@#{p['discord_id']}>"}.join(" ")
            $target_channel.send_message("#{mention}\n[#{recruitment['label_id']}] の予定時間です。(*´∀`)ﾉ ｲﾃﾗｰ")
            $target_channel.send_message("```\n#{format_recruitment_to_string(recruitment)}\n```")
            $target_channel.send_message("[#{recruitment['label_id']}] は予定時間になったので終了します。")
            $target_channel.send_message(recruitments_message)
          end
          TwitterController.recruitment_close(recruitment)
        end
      else
        if (recruitment['created_at'].in_time_zone + EXPIRE_TIME) < Time.zone.now
          Api::Recruitment.destroy(recruitment)
          $target_channel.send_message("[#{recruitment['label_id']}] は期限を過ぎたので終了します。")
          $target_channel.send_message(recruitments_message)
          TwitterController.recruitment_close(recruitment)
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

  def recruitments_message
    recruitments = JSON.parse(Api::Recruitment.index.body)
    return "```\n募集はありません\n```" if recruitments.blank?
    recruitment_message = recruitments.sort_by{|recruitment|
      recruitment['label_id']
    }.map{|recruitment|
      format_recruitment_to_string(recruitment)
    }.join("\n")
    return "```\n#{recruitment_message}\n```"
  end

  def open(message_event)
    recruit_message = get_message_content(message_event)
    recruitment = JSON.parse(Api::Recruitment.create(content: recruit_message, reserve_at: extraction_time(recruit_message).to_s).body)
    Api::Participant.join(recruitment, name: message_event.author.username, discord_id: message_event.author.id)
    if recruitment['reserve_at'].present?
      message_event.send_message("[#{recruitment['label_id']}] を予定時間 #{view_datetime(recruitment['reserve_at'])} で受け付けました。")
    else
      message_event.send_message("[#{recruitment['label_id']}] を期限 #{view_datetime(recruitment['created_at'].in_time_zone + EXPIRE_TIME)} で受け付けました。")
    end
    message_event.send_message(recruitments_message)
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
        message_event.send_message("[#{recruitment['label_id']}] を終了しました。")
        message_event.send_message(recruitments_message)
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
        Api::Participant.join(recruitment, name: message_event.author.username, discord_id: message_event.author.id)
        message_event.send_message("#{message_event.author.username}さんが [#{recruitment['label_id']}] に参加しました。")
        message_event.send_message(recruitments_message)
        TwitterController.recruitment_join(recruitment)
        if recruitment['participants'].size >= extraction_recruit_user_count(recruitment['content'])
          recruitment = update_recruitment(recruitment)
          Api::Recruitment.destroy(recruitment)
          message_event.send_message("メンバーが集まったので [#{recruitment['label_id']}] を終了しました。")
          message_event.send_message(recruitments_message)
          TwitterController.recruitment_close(recruitment)
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
          message_event.send_message("#{message_event.author.username}さんが [#{recruitment['label_id']}] の参加をキャンセルしました。")
          message_event.send_message(recruitments_message)
          TwitterController.recruitment_leave(recruitment)
          return
        end
      end
    end
  end
end
