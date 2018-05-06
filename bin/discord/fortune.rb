module Fortune
  extend self

  LIST = %w(アルティメット大吉 シャイニング大吉 スパイラル大吉 エクストリーム大吉 ファイナル大吉 超超超大吉 超大吉 文句なしの大吉 どうあがいても大吉 大吉 卍吉 ぎりぎりの大吉 そこそこの大吉 太吉 犬吉 ちょうどいい中吉 それなりの中吉 ゆる吉 ダメ吉 前向きな大凶 マイルドな大凶 半分は優しさの大凶 大凶 暗黒大魔凶 ダークネス☆大凶 ハズレ(´・ω・｀) )

  def get(message_event)
    message_event.send_message("<@#{message_event.author.id}> #{LIST[Random.new(message_event.author.id + Date.today.ld).rand(LIST.size)]}")
  end
end
