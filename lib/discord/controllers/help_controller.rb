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

    if $play_channel == message_event.channel
      ret << "__記憶機能__"
      ret << ""
      ret << "`記憶 <キーワード> <説明>` - <キーワード> を <説明> と記憶"
      ret << "`<キーワード>` - <キーワード> に対応する <説明> を表示"
      ret << "`忘却 <キーワード>` - <キーワード> を忘却"
      ret << "`リスト` - キーワード一覧を表示"
      ret << ""
    end

    if $play_channel == message_event.channel
      ret << "__飯テロ機能__"
      ret << ""
      ret << "`お腹空いた` - おいしい(たぶん)食事の画像を表示"
      ret << ""
    end

    if $play_channel == message_event.channel
      ret << "__お天気機能__"
      ret << ""
      ret << "`<場所>の天気` - 指定した場所の天気を表示"
      ret << ""
    end

    if $play_channel == message_event.channel
      ret << "__おみくじ機能__"
      ret << ""
      ret << "`おみくじ` - 今日の運勢を表示"
      ret << ""
    end

    if $play_channel == message_event.channel
      ret << "__あだ名作成機能__"
      ret << ""
      ret << "`あだ名` - 今日のあだ名を命名"
      ret << ""
    end

    if ret.present?
      message_event.send_message(ret.join("\n"))
    end
  end
end
