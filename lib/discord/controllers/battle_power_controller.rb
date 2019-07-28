module BattlePowerController
  extend self

  BATTLE_POWER_LIST = %w(
    5 農夫
    416 ラディッツ編の悟空
    924 ラディッツ編でかめはめ波を撃つときの悟空
    1330 ピッコロ
    1307 怒りパワー全開の悟飯
    139 亀仙人
    206 クリリン
    250 天津飯
    177 ヤムチャ
    1200 栽培マン
    2800 ベジータ編の悟飯
    21000 3倍界王拳の悟空
    1000 ナメックの若者
    42000 ネイル
    0 気を消した状態のクリリン
    18000 ベジータ
    180000 フリーザ編の悟空
    120000 ギニュー
    530000 フリーザ
    1000000 フリーザ第二形態
    5 トランクス
    150000000 超サイヤ人の悟空
    0.001 ウミガメ
    10000 バーダック
    2 赤ん坊のカカロット
    10000 生まれたばかりのブロリー
    5300000000 ユニバーサル・スタジオ・ジャパンのアトラクションに出てくるフリーザ
    260 若い頃のピッコロ大魔王
    1500 ラディッツ
    610 餃子
    4000 ナッパ
    18000 キュイ
    23000 ザーボン
    22000 ドドリア
    130 チチ
    970 ヤジロベー
    210 桃白白
    190 カリン
    1030 ミスターポポ
    3500 界王
    2500000000 ゴジータ
    1400000000 超サイヤ人ブロリー
  )

  def do(message_event)
    index = rand(BATTLE_POWER_LIST.size/2)
    battle_power = BATTLE_POWER_LIST[index*2]
    character = BATTLE_POWER_LIST[index*2+1]
    message_event.send_message(I18n.t('battle_power.display', name: message_event.author.display_name, battle_power: battle_power, character: character))
  end
end
