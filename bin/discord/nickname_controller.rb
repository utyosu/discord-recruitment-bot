module NicknameController
  extend self

  PREFIX = %w(アルティメット グレート シャイニング プレシャス ヘルフレイム ガルウィング マキシマム プリンセス ファイナル ギガブレイク ダークネス ゴッドハンド ニンジャスレイヤー ブルーレット 魔王 闇より舞い降りし 光の戦士 ひねくれ者の 納豆大好き ホーミング 神の使いである ゴッド・オブ・ 妖怪 トランスフォーマー 一万年と二千年前から プロ気取りの 死神 皇帝 貴公子 ミスター ロボ 暴走機関車 反逆の 断罪の レインボー 地獄から蘇りし ジェームス・  美しき 金の亡者 不死鳥 最強の 清楚な 強欲なる 金剛の 鋼の キング とっとこ それいけ めざせ 赤き血の いきなり 撲殺天使 怪盗 学級王 機動戦士 グラップラー 美少女 恋する 交響詩篇 さすらいの サラリーマン 神撃の 正義の 闇落ち 閃光の 創聖の 名探偵 エンジェル オッス！オラ 新世紀 星の 魔界戦記 魔女っ子 魔法少女)

  SUFFIX = %w(ちゃん っち ちょす 様 君 娘 兄貴 陛下 殿下 姫 公 卿 殿 王子 先生 教授 会長 社長 部長 課長 係長 宴会部長 氏www 嬢 坊 先輩 長老 村長 市長 大統領 総理 大臣 閣下 大魔神 大魔王 大王 番長 特攻隊長 大将 軍曹 選手 名人 十段 チャンピオン 師匠 太郎 容疑者 ンゴ 助 パパ ママ エル 地蔵 マン エリオン ボーイ ぴっぴ♪ でござる と愉快な仲間達 Z ぽん ・ザ・キッド ・ザ・ハーデス ゾネス 神殿 草 ウホ ボス ゾンビ キュア マスター 丸 号 ンち SOS ロボ セブン の奇妙な冒険 えもん ゲリオン)

  def do(message_event)
    r = Random.new(message_event.author.id + Date.today.ld)
    name = message_event.author.display_name.dup
    (PREFIX + SUFFIX).each{|k|name.gsub!(/#{k}/, "")}
    nick = "#{PREFIX[r.rand(PREFIX.size)]}#{name}#{SUFFIX[r.rand(SUFFIX.size)]}"
    if message_event.author.display_name != nick
      message_event.send_message("<@#{message_event.author.id}>よ…今日からお前は「#{nick}」だ！")
      message_event.author.nick = nick
    end
  end
end
