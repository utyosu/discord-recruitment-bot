module HelpController
  extend self

  def help(message_event)
    ret = []

    if $recruitment_channel == message_event.channel
      ret << "__募集機能__"
      ret << ""
      ret << "`@<数字>` - 募集の開始"
      ret << "`<数字>参加` - 募集に参加"
      ret << "`<数字>キャンセル` - 募集から参加をキャンセル"
      ret << "`<数字>しめ` - 募集を終了"
      ret << "`復活` - 最後に締めた募集を復活"
      ret << "`案件` - 現在の募集を表示"
      ret << ""
    end

    if ret.present?
      message_event.send_message(ret.join("\n"))
    end
  end
end
