module Keywords
  # 募集開始キーワード
  OPEN_RECRUITMENT = /@\d+/

  # 募集終了キーワード
  CLOSE_RECRUITMENT = /しめ|締め|〆|滅|sime|shime/

  # 参加キーワード
  JOIN_RECRUITMENT = /いく|行く|いき|行き|やる|やりま|さんか|参加|ひゃっはー|うほ|ウホ|ごわす|ゴワス|参る|わっしょい|卍|go|join|участие|Συμμετοχή|参与|參與|참여|ပါဝင်ဆောင်ရွက်/

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

  # 対話反応キーワード
  INTERACTION_RESPONSE = /リスト/

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

  # 使い方キーワード
  HELP_RESPONSE = /使い方|ヘルプ|help/
end
