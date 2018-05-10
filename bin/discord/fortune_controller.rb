module FortuneController
  extend self

  PREFIX = %w(
    アルティメット
    シャイニング
    スパイラル
    エクストリーム
    ファイナル
    文句なしの
    どうあがいても
    ぎりぎりの
    そこそこの
    ちょうどいい
    それなりの
    前向きな
    マイルドな
    半分は優しさの
    ダークネス
    もうちょっとで
    激マブの
    イケイケの
    明日は
    昨日は
    今から10秒だけ
    やや
    チョベリグの
    モーレツに
    ナウい
    イエス
    ある程度は
    割と
    いい感じの
    ラッキーな
    ナイスな
    救いようのない
    惜しい
    敗北感のある
    心温まる
  )

  WORD = %w(
    超吉
    大吉
    太吉
    犬吉
    大古
    天吉
    マジ吉
    卍吉
    秀吉
    吉
    中吉
    小吉
    半吉
    1/4吉
    後吉
    末吉
    凶
    小凶
    半凶
    末凶
    大凶
    又吉
    暗黒大魔凶
  )

  def get(message_event)
    return if !check_limit(message_event, "fortune", ENV['DISCORD_BOT_FORTUNE_LIMIT'] || 1)
    message_event.send_message("#{message_event.author.display_name} : #{PREFIX[rand(PREFIX.size)] + WORD[rand(WORD.size)]}")
  end
end
