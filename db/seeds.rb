user = User.find_or_create_by(discord_id: "123123123", name: "テストさん")
reserve_at = 30.minutes.since

recruitment = Recruitment.create(content: "#{reserve_at.strftime("%H:%M")}よりサーモンラン@1")
recruitment.participants.create(user: user)

recruitment = Recruitment.create(content: "#{reserve_at.strftime("%H:%M")}よりリーグマッチ@2")
recruitment.participants.create(user: user)
