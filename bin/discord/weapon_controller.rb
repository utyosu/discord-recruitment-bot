module WeaponController
  extend self

  WEAPON_MAIN_KIND = %w(
    スプラシューターコラボ
    .52ガロン
    わかばシューター
    オクタシューターレプリカ
    .96ガロンデコ
    シャープマーカー
    N-ZAP89
    N-ZAP85
    プライムシューター
    シャープマーカーネオ
    ボールドマーカー
    ボールドマーカーネオ
    プロモデラーRG
    スプラシューター
    .52ガロンデコ
    L3リールガンD
    ジェットスイーパーカスタム
    プライムシューターコラボ
    もみじシューター
    プロモデラーMG
    .96ガロン
    ヒーローシューターレプリカ
    L3リールガン
    ジェットスイーパー
    H3リールガン
    H3リールガンD
    ボトルカイザー
    ボトルカイザーフォイル
    スプラシューターベッチュー
    デュアルスイーパー
    デュアルスイーパーカスタム
    スプラマニューバー
    スプラマニューバーコラボ
    スパッタリー
    ヒーローマニューバーレプリカ
    ケルビン525
    スパッタリー・ヒュー
    クアッドホッパーブラック
    ケルビン525デコ
    クアッドホッパーホワイト
    スプラマニューバーベッチュー
    スプラスコープ
    スクイックリンα
    スプラチャージャー
    14式竹筒銃・甲
    ヒーローチャージャーレプリカ
    スクリックリンβ
    14式竹筒銃・乙
    ソイチューバー
    スプラチャージャーコラボ
    スプラスコープコラボ
    リッター4K
    4Kスコープ
    リッター4Kカスタム
    4Kスコープカスタム
    ソイチューバーカスタム
    スプラチャージャーベッチュー
    スプラスコープベッチュー
    ノヴァブラスターネオ
    ロングブラスターカスタム
    ホットブラスターカスタム
    ノヴァブラスター
    ラピッドブラスター
    ホットブラスター
    Rブラスターエリートデコ
    Rブラスターエリート
    ラピッドブラスターデコ
    ロングブラスター
    クラッシュブラスター
    ヒーローブラスターレプリカ
    クラッシュブラスターネオ
    ダイナモローラー
    スプラローラーコラボ
    カーボンローラー
    ダイナモローラーテスラ
    スプラローラー
    カーボンローラーデコ
    ヒーローローラーレプリカ
    ヴァリアブルローラー
    ヴァリアブルローラーフォイル
    スプラローラーベッチュー
    ホクサイ
    パブロ
    ホクサイ・ヒュー
    パブロ・ヒュー
    ヒーローブラシレプリカ
    バケットスロッシャー
    ヒッセン
    スクリュースロッシャー
    バケットスロッシャーデコ
    ヒッセン・ヒュー
    スクリュースロッシャーネオ
    ヒーロースロッシャーレプリカ
    エクスプロッシャー
    オーバーフロッシャー
    スプラスピナーコラボ
    バレルスピナーデコ
    ハイドラントカスタム
    バレルスピナー
    ハイドラント
    スプラスピナー
    ヒーロースピナーレプリカ
    クーゲルシュライバー
    ノーチラス47
    パラシェルター
    ヒーローシェルターレプリカ
    キャンピングシェルター
    スパイガジェット
    パラシェルターソレーラ
    キャンピングシェルターソレーラ
  ).map{|k|Regexp.escape(k)}

  def do(message_event)
    return if !check_limit(message_event, "play", ENV['DISCORD_BOT_PLAY_LIMIT'] || 10)
    message_event.send_message("#{message_event.author.display_name}さんの今日のオススメブキは【**#{WEAPON_MAIN_KIND.sample}**】でし！")
  end
end