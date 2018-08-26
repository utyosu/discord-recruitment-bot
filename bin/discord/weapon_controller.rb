module WeaponController
  extend self

  WEAPON_MAIN_KIND = %w(
    スプラシューター
    .52ガロン
    わかばシューター
    オクタシューター
    .96ガロン
    シャープマーカー
    N-ZAP
    プライムシューター
    ボールドマーカー
    プロモデラー
    L3リールガン
    ジェットスイーパー
    もみじシューター
    H3リールガン
    ボトルカイザー
    デュアルスイーパー
    スプラマニューバー
    スパッタリー
    ヒーローマニューバー
    ケルビン525
    スパッタリー
    クアッドホッパー
    スプラチャージャー
    スクイックリン
    14式竹筒銃
    ヒーローチャージャー
    ソイチューバー
    リッター4K
    ノヴァブラスター
    ロングブラスター
    ホットブラスター
    ラピッドブラスター
    Rブラスターエリート
    クラッシュブラスター
    ヒーローブラスター
    ダイナモローラー
    スプラローラー
    カーボンローラー
    ヒーローローラー
    ヴァリアブルローラー
    ホクサイ
    パブロ
    ヒーローブラシ
    バケットスロッシャー
    ヒッセン
    スクリュースロッシャー
    ヒーロースロッシャー
    エクスプロッシャー
    スプラスピナー
    バレススピナー
    ハイドラント
    ヒーロースピナー
    クーゲルシュライバー
    パラシェルター
    ヒーローシェルター
    キャンピングシェルター
    スパイガジェット
  ).map{|k|Regexp.escape(k)}

  WEAPON_MAIN_OPTION = %w(
    コラボ
    レプリカ
    デコ
    89
    85
    ネオ
    RG
    MG
    D
    カスタム
    フォイル
    ・ヒュー
    ブラック
    スコープ
    α
    ・甲
    β
    ・乙
    スコープ
    スコープコラボ
    スコープカスタム
    テスラ
    ソレーラ
  ).map{|k|Regexp.escape(k)}


  WEAPON_SUB_KIND = %w(
    スプラッシュ
    キューバン
    クイック
    スプリンクラー
    ジャンプ
    ポイント
    トラップ
    カーリング
    ロボット
    ポイズン
    チェイス
  ).map{|k|Regexp.escape(k)}

  WEAPON_SUB_OPTION = %w(
    ボム
    ビーコン
    シールド
    センサー
    ミスト
    ボール
  ).map{|k|Regexp.escape(k)}

  WEAPON_SPECIAL_KIND = %w(
    ジェット
    スーパー
    マルチ
    ハイパー
    アメ
    キューバンボム
    スプラッシュボム
    カーリングボム
    ロボットボム
    インク
    イカ
    バブル
    ダイオウ
    メガホン
  ).map{|k|Regexp.escape(k)}

  WEAPON_SPECIAL_OPTION = %w(
    パック
    チャクチ
    ミサイル
    プレッサー
    フラシ
    ピッチャー
    アーマー
    スフィア
    ランチャー
    センサー
    イカ
    トルネード
    ショット
    レーザー
    ラッシュ
  ).map{|k|Regexp.escape(k)}

  def do(message_event)
    return if !check_limit(message_event, "play", ENV['DISCORD_BOT_PLAY_LIMIT'] || 10)
    weapon_main = "#{WEAPON_MAIN_KIND.sample}#{WEAPON_MAIN_OPTION.sample}"
    weapon_sub = "#{WEAPON_SUB_KIND.sample}#{WEAPON_SUB_OPTION.sample}"
    weapon_special = "#{WEAPON_SPECIAL_KIND.sample}#{WEAPON_SPECIAL_OPTION.sample}"
    message_event.send_message("#{message_event.author.display_name}さんの今日のオススメブキは【**#{weapon_main}**】でし！\nサブウェポンは【**#{weapon_sub}**】で、スペシャルは【**#{weapon_special}**】でし！")
  end
end
