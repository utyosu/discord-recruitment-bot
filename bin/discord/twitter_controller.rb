class TwitterController
  @@twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  def self.recruitment_open(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.recruitment_close(recruitment)
    tweet(recruitment, "【#{ENV['TWITTER_NOTICE_TITLE']}】\nこの募集は終了しました。")
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
    message = "【#{ENV['TWITTER_NOTICE_TITLE']}】\n#{recruitment['content']} by #{recruitment['participants'].first['name']} (#{recruitment['participants'].size-1}/#{extraction_recruit_user_count(recruitment['content'])})"
    if recruitment['participants'].present? && 1 < recruitment['participants'].size
      message += "\n参加者: #{recruitment['participants'][1..-1].map{|a|a['name']}.join(", ")}"
    end
    return message
  end

  def self.tweet(recruitment, message)
    return if ENV['TWITTER_DISABLE'].present?
    begin
      tweet = @@twitter_client.update(message, in_reply_to_status_id: recruitment['tweet_id'])
      Api::Recruitment.update(recruitment, {tweet_id: tweet.id})
    rescue Twitter::Error => e
      STDERR.puts e.message
    end
  end
end
