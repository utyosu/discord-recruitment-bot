module Recruitment
  extend self

  def show(message_event)
    message_event.send_message(recruitments_message)
  end

  def destroy_expired_recruitment
    recruitments = JSON.parse(Api::Recruitment.index.body)
    destroyed_indexes = []
    recruitments.each do |recruitment|
      if recruitment['expired_at'].in_time_zone < Time.zone.now
        Api::Recruitment.destroy(recruitment['id'])
        destroyed_indexes.push(recruitment['label_id'])
      end
    end
    if destroyed_indexes.present?
      $target_channels.each do |channel|
        channel.send_message("募集 #{destroyed_indexes.map{|a|"[#{a}]"}.join} は期限を過ぎたので終了します。")
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
      recruitment_message += "[#{recruitment['label_id']}] #{recruitment['content']} by #{recruitment['participants'].first['name']} (#{recruitment['participants'].size-1})\n"
      if 2 <= recruitment['participants'].size
        recruitment['participants'][1..-1].each do |participant|
          recruitment_message += "    - #{participant['name']}\n"
        end
      end
      recruitment_message += "\n"
    }
    return "```\n#{recruitment_message}\n```"
  end

  def open(message_event)
    recruitment = JSON.parse(Api::Recruitment.create(get_message_content(message_event), extraction_time(get_message_content(message_event))).body)
    Api::Participant.join(recruitment['id'], message_event.author)
    message_event.send_message("募集 [#{recruitment['label_id']}] を期限 #{view_datetime(recruitment['expired_at'])} で受け付けました。")
    message_event.send_message(recruitments_message)
  end

  def close(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    my_discord_id = message_event.author.id.to_s
    closed_indexes = []
    JSON.parse(Api::Recruitment.index.body).each do |recruitment, recruitment_index|
      if number == recruitment['label_id']
        Api::Recruitment.destroy(recruitment['id'])
        closed_indexes.push(recruitment['label_id'])
      end
    end
    if closed_indexes.present?
      message_event.send_message("#{closed_indexes.sort.map{|a|"[#{a}]"}.join} の募集を終了しました。")
      message_event.send_message(recruitments_message)
    end
  end

  def join(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    recruitments = JSON.parse(Api::Recruitment.index.body)
    joined_indexes = []
    recruitments.each do |recruitment|
      if number == recruitment['label_id'] && !recruitment['participants'].any?{|p|p['discord_id'] == message_event.author.id.to_s}
        Api::Participant.join(recruitment['id'], message_event.author)
        joined_indexes.push(recruitment['label_id'])
      end
    end
    if joined_indexes.present?
      message_event.send_message("#{joined_indexes.sort.map{|a|"[#{a}]"}.join} に参加しました。")
      message_event.send_message(recruitments_message)
    end
  end

  def leave(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number.blank?
    my_discord_id = message_event.author.id.to_s
    leaved_indexes = []
    JSON.parse(Api::Recruitment.index.body).each do |recruitment|
      next if number != recruitment['label_id']
      recruitment['participants'].each do |participant|
        if participant['discord_id'] == my_discord_id
          Api::Participant.leave(recruitment['id'], participant['id'])
          leaved_indexes.push(recruitment['label_id'])
        end
      end
    end
    if leaved_indexes.present?
      message_event.send_message("#{leaved_indexes.sort.map{|a|"[#{a}]"}.join} の参加をキャンセルしました。")
      message_event.send_message(recruitments_message)
    end
  end
end
