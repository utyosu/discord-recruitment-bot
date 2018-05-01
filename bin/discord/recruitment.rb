module Recruitment
  extend self

  def show(message_event)
    message_event.send_message(recruitments_message)
  end

  def destroy_expired_recruitment
    recruitments = JSON.parse(Api::Recruitment.index.body)
    destroyed_recruitments = []
    recruitments.each do |recruitment|
      if recruitment['expired_at'].in_time_zone < Time.zone.now
        Api::Recruitment.destroy(recruitment)
        destroyed_recruitments.push(recruitment)
      end
    end
    if destroyed_recruitments.present?
      $target_channels.each do |channel|
        channel.send_message("募集 #{destroyed_recruitments.map{|a|"[#{a['label_id']}]"}.join} は期限を過ぎたので終了します。")
        channel.send_message(recruitments_message)
      end
    end
  end

  def recruitments_message
    recruitments = JSON.parse(Api::Recruitment.index.body)
    return "```\n募集はありません\n```" if recruitments.blank?
    recruitment_message = ""
    recruitments.sort_by{|recruitment|
      recruitment['label_id']
    }.each{|recruitment|
      recruitment_message += "[#{recruitment['label_id']}] #{recruitment['content']} by #{recruitment['participants'].first['name']} (#{recruitment['participants'].size-1}/#{extraction_recruit_number(recruitment['content'])})\n"
      if 2 <= recruitment['participants'].size
        recruitment_message += "    参加者: #{recruitment['participants'][1..-1].map{|p|p['name']}.join(', ')}\n"
      end
    }
    return "```\n#{recruitment_message}\n```"
  end

  def open(message_event)
    recruit_message = get_message_content(message_event)
    recruitment = JSON.parse(Api::Recruitment.create(content: recruit_message, expired_at: extraction_time(recruit_message).to_s).body)
    Api::Participant.join(recruitment, name: message_event.author.username, discord_id: message_event.author.id)
    message_event.send_message("募集 [#{recruitment['label_id']}] を期限 #{view_datetime(recruitment['expired_at'])} で受け付けました。")
    message_event.send_message(recruitments_message)
    TwitterManager.recruitment_open(message_event, recruitment)
  end

  def close(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    my_discord_id = message_event.author.id.to_s
    closed_recruitments = []
    JSON.parse(Api::Recruitment.index.body).each do |recruitment, recruitment_index|
      if number == recruitment['label_id']
        Api::Recruitment.destroy(recruitment)
        message_event.send_message("[#{recruitment['label_id']}] の募集を終了しました。")
        message_event.send_message(recruitments_message)
        TwitterManager.recruitment_close(message_event, recruitment)
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
        message_event.send_message("[#{recruitment['label_id']}] に参加しました。")
        message_event.send_message(recruitments_message)
        TwitterManager.recruitment_join(message_event, recruitment)
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
          message_event.send_message("[#{recruitment['label_id']}] の参加をキャンセルしました。")
          message_event.send_message(recruitments_message)
          TwitterManager.recruitment_leave(message_event, recruitment)
          return
        end
      end
    end
  end
end
