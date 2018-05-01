class TwitterController
  @@twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  def self.recruitment_open(message_event, recruitment)
    tweet(message_event, recruitment, recruitment_message(message_event, recruitment))
  end

  def self.recruitment_close(message_event, recruitment)
    tweet(message_event, recruitment, "【#{ENV['TWITTER_NOTICE_TITLE']}】\nこの募集は終了しました。")
  end

  def self.recruitment_join(message_event, recruitment)
    tweet(message_event, recruitment, recruitment_message(message_event, recruitment))
  end

  def self.recruitment_leave(message_event, recruitment)
    tweet(message_event, recruitment, recruitment_message(message_event, recruitment))
  end

  private

  def self.recruitment_message(message_event, recruitment)
    recruitment = JSON.parse(Api::Recruitment.index.body).find{|r|r['id'] == recruitment['id']}
    message = "【#{ENV['TWITTER_NOTICE_TITLE']}】\n#{recruitment['content']} by #{message_event.author.username} (#{recruitment['participants'].size-1}/#{extraction_recruit_number(recruitment['content'])})"
    if recruitment['participants'].present? && 1 < recruitment['participants'].size
      message += "\n参加者: #{recruitment['participants'][1..-1].map{|a|a['name']}.join(", ")}"
    end
    return message
  end

  def self.tweet(message_event, recruitment, message)
    tweet = @@twitter_client.update(message, in_reply_to_status_id: recruitment['tweet_id'])
    Api::Recruitment.update(recruitment, {tweet_id: tweet.id})
  end
end
