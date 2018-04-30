namespace :dev do
  task create_test_data: :environment do
    r = Recruitment.create!(content: "サーモンラン募集＠３", expired_at: DateTime.now+Rational(1, 24))
    r.participants.create!(discord_id: "00000000", name: "テストくん")
    r.participants.create!(discord_id: "00000001", name: "テストちゃん")
  end
end
