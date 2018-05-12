module NicknameController
  extend self

  PREFIX = %w(アルティメット グレート シャイニング スーパー プレシャス ヘルフレイム ブラックサンダー アニバーサリー バーサーカー ギャラクシー ガルウィング マキシマム プリンセス ファイナル ギガブレイク ダークネス ゴッドハンド ナイスミドル ニンジャスレイヤー ブルーレット 魔王 闇より舞い降りし 光の戦士 ひねくれ者の 納豆大好き おにぎり大好き ホーミング 神の使いである ゴッド・オブ・ 妖怪 トランスフォーマー 一万年と二千年前から プロ気取りの 死神 皇帝 貴公子 ミスター ロボ 暴走機関車 反逆の 断罪の レインボー 地獄から蘇りし ジェームス・  美しき 金の亡者 不死鳥 最強の 清楚な 強欲なる 金剛の 鋼の キング とっとこ それいけ めざせ 赤き血の いきなり 撲殺天使 怪盗 学級王 機動戦士 グラップラー 美少女 恋する 交響詩篇 さすらいの サラリーマン 神撃の 正義の 闇落ち 閃光の 創聖の 名探偵 エンジェル オッス！オラ 新世紀 星の 魔界戦記 魔女っ子 魔法少女 ポイズン アメリカン ヘルシェイク デビル ジャスティス 株式会社 マダム 風の谷の 紅の 崖の上の 借りぐらしの どすこい ひょっこり ゾンビになった 前向きな とにかく明るい 世界の いきいき キューティー ビューティフル ミラクル ナルシスト デンジャラス ポエマー 太っ腹な ゴージャス イケメン もりもり はらぺこ 悲しみを乗り越えた 破壊神 三代目 かっとび 高貴なる ちゃっかり うっかり 無敵の 戦艦・ 愛と勇気の 明日から頑張る 綺麗な 伝説の 流星の 炎の料理人 ゲゲゲの).map{|k|Regexp.escape(k)}.sort_by{|k|k.length}.reverse

  SUFFIX = %w(ちゃん さん っち たん きゅん おじさん おばさん 爺 子 大明神 様 君 娘 兄貴 陛下 座長 殿下 姫 公 卿 殿 王子 先生 教授 会長 社長 部長 課長 係長 宴会部長 氏 嬢 坊 先輩 長老 村長 市長 大統領 総理 大臣 閣下 大魔神 大魔王 大王 番長 特攻隊長 大将 軍曹 選手 名人 十段 チャンピオン 師匠 太郎 容疑者 ンゴ 助 パパ ママ エル 地蔵 マン エリオン ボーイ ぴっぴ♪ でござる と愉快な仲間達 Z ぽん ・ザ・キッド ・ザ・ハーデス ・ザ・ゴッド ゾネス 神殿 ビル 草 ウホ ボス キュア マスター 丸 号 ンち SOS ロボ セブン の奇妙な冒険 えもん ゲリオン 工務店 ブラザーズ 親方 横綱 (18歳) (3歳) ッティ 3世 バスターズ か…いい奴だったよ って誰だっけ？ は静かに暮らしたい ～そして伝説へ…～ 博士 モン 銀行 運送 の丸焼き 神社 サポートセンター 花子 という名の紳士 画伯 48 の兄 の妹 の勝ちデース 死す。デュエルスタンバイ！ 完全体 勇者 テクニシャン デザイナー ハンター パティシエ 寿司職人 ソムリエ シェフ ブリーダー は星になったのサ… ならあっちに行ったぜ).map{|k|Regexp.escape(k)}.sort_by{|k|k.length}.reverse

  DECORATION = %w(☆ † 卍 ♪ ❤ 💪).map{|k|Regexp.escape(k)}

  def do(message_event)
    return if !check_limit(message_event, "play", ENV['DISCORD_BOT_PLAY_LIMIT'] || 10)
    name = message_event.author.display_name.dup
    DECORATION.each{|k|name.gsub!(/\A#{k}|#{k}\Z/,"")}
    PREFIX.each{|k|name.gsub!(/\A#{k}/, "")}
    SUFFIX.each{|k|name.gsub!(/#{k}\Z/, "")}
    nick = "#{PREFIX.sample}#{name}#{SUFFIX.sample}"
    if rand(6) == 0
      decoration = DECORATION.sample
      nick = "#{decoration}#{nick}#{decoration}"
    end
    if message_event.author.display_name != nick && nick.length <= 32
      message_event.send_message("#{message_event.author.display_name}よ…今日からお前は「#{nick}」だ！")
    end
  end
end
