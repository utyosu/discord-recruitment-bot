class TwitterController
  @@twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['DISCORD_BOT_TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['DISCORD_BOT_TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['DISCORD_BOT_TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['DISCORD_BOT_TWITTER_ACCESS_TOKEN_SECRET']
  end

  def self.recruitment_open(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.recruitment_close(recruitment)
    tweet(recruitment, "【#{ENV['DISCORD_BOT_TWITTER_NOTICE_TITLE']}】(ID:#{recruitment['id']})\nこの募集は終了しました。")
  end

  def self.recruitment_join(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.recruitment_leave(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  private

  def self.recruitment_message(recruitment)
    recruitment = update_recruitment(recruitment)
    message = "【#{ENV['DISCORD_BOT_TWITTER_NOTICE_TITLE']}】(ID:#{recruitment['id']})\n#{recruitment['content']} by #{recruitment['participants'].first['name']} (#{recruitment['participants'].size-1}/#{extraction_recruit_user_count(recruitment['content'])})"
    if recruitment['participants'].present? && 1 < recruitment['participants'].size
      message += "\n参加者: #{recruitment['participants'][1..-1].map{|a|a['name']}.join(", ")}"
    end
    return message
  end

  def self.tweet(recruitment, message)
    return if ENV['DISCORD_BOT_TWITTER_DISABLE'].present?
    begin
      tweet = @@twitter_client.update(message, in_reply_to_status_id: recruitment['tweet_id'])
      Api::Recruitment.update(recruitment, {tweet_id: tweet.id})
    rescue Twitter::Error => e
      STDERR.puts e.message
    end
  end
end
