module Settings
  # 募集開始キーワード
  OPEN_RECRUITMENT = /@\d+/

  # 募集終了キーワード
  CLOSE_RECRUITMENT = /しめ|締め|〆|滅|sime|shime/

  # 参加キーワード
  JOIN_RECRUITMENT = /いく|行く|いき|行き|やる|やりま|さんか|参加|ひゃっはー|うほ|ウホ|ごわす|ゴワス|参る|わっしょい|卍|go|join|участие|Συμμετοχή|参与|參與|참여|ပါဝင်ဆောင်ရွက်|ぴえん|ボールド|もげ|もち|もに|sanka/

  # 参加キャンセルキーワード
  LEAVE_RECRUITMENT = /キャンセル|悲しみ/

  # 募集復活キーワード
  RESURRECTION_RECRUITMENT = /戻して|もどして|復活/

  # 募集状況確認キーワード
  SHOW_RECRUITMENT = /案件/

  # 対話セット登録キーワード
  INTERACTION_CREATE = /記憶/

  # 対話セット削除キーワード
  INTERACTION_DESTROY = /忘却/

  # 飯テロキーワード
  FOOD_RESPONSE = /おなか|お腹|飯テロ/

  # 天気キーワード
  WEATHER_RESPONSE = /\A(.+)の(天気|てんき)/

  # おみくじキーワード
  FORTUNE_RESPONSE = /おみくじ/

  # ニックネームキーワード
  NICKNAME_RESPONSE = /あだな|あだ名|通り名|ニックネーム/

  # ブキキーワード
  WEAPON_RESPONSE = /ブキ|ぶき|武器/

  # ブキキーワード
  LUCKY_COLOR_RESPONSE = /ラッキー/

  # 戦闘力キーワード
  BATTLE_POWER_RESPONSE = /戦闘力|スカウター/

  # インサイダーゲームキーワード
  INSIDER_GAME_KEYWORD = /\Aインサイダーゲーム/

  # 使い方キーワード
  HELP_RESPONSE = /使い方|ヘルプ|help/

  # 会話機能のキーワード
  TALK_REGEXP = /\A(.*)#{ENV['DISCORD_BOT_TALK_WORD']}(.*)\Z/

  # 時間指定のない募集の期限
  EXPIRE_TIME = 1.hours

  # 予約募集の期限
  RESERVE_OVER_TIME = 30.minutes

  # 遊び機能の制限が解除される時刻 (8時=8.hours)
  REFRESH_TIME = 8.hours
end
