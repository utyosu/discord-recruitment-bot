class TwitterController
  @twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = Settings.secret.twitter.consumer_key
    config.consumer_secret = Settings.secret.twitter.consumer_secret
    config.access_token = Settings.secret.twitter.access_token
    config.access_token_secret = Settings.secret.twitter.access_token_secret
  end

  def self.recruitment_open(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.recruitment_close(recruitment)
    tweet(recruitment, "#{I18n.t("twitter.title")}\n#{I18n.t('twitter.close')}")
  end

  def self.recruitment_join(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.recruitment_leave(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.ready?
    ENV['DISCORD_BOT_TWITTER_DISABLE'].blank?
  end

  def self.recruitment_message(recruitment)
    message = []
    message << I18n.t("twitter.title")
    message << I18n.t("twitter.content", content: recruitment.content, author_name: recruitment.author.name, reserved: recruitment.reserved, capacity: recruitment.capacity)
    message << I18n.t("twitter.participants", participants: recruitment.participants[1..-1].map { |a| a.user.name }.join(", ")) if 0 < recruitment.reserved
    return message.join("\n")
  end

  def self.tweet(recruitment, message)
    return unless ready?
    begin
      tweet = @twitter_client.update(to_twitter_safe(message), in_reply_to_status_id: recruitment.tweet_id)
      recruitment.update(tweet_id: tweet.id)
    rescue Twitter::Error => e
      STDERR.puts e.message
    end
  end

  def self.to_twitter_safe(str)
    ret = str.dup
    str.scan(/[＠@]\d+/) do |word|
      ret.gsub!(/#{Regexp.escape(word)}/, word.tr('0-9@', '０-９＠'))
    end
    ret.tr!('*', '＊')
    return ret
  end
end
