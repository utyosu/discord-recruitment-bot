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
    tweet(recruitment, "【#{ENV['DISCORD_BOT_TWITTER_NOTICE_TITLE']}】\n#{I18n.t('twitter.close')}")
  end

  def self.recruitment_join(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  def self.recruitment_leave(recruitment)
    tweet(recruitment, recruitment_message(recruitment))
  end

  private

  def self.recruitment_message(recruitment)
    message = "【#{ENV['DISCORD_BOT_TWITTER_NOTICE_TITLE']}】\n#{recruitment.content} by #{recruitment.author.name} (#{recruitment.reserved}/#{recruitment.capacity})"
    message += "\n#{I18n.t('twitter.participants')}: #{recruitment.participants[1..-1].map{|a|a.user.name}.join(", ")}" if 0 < recruitment.reserved
    return message
  end

  def self.tweet(recruitment, message)
    return if ENV['DISCORD_BOT_TWITTER_DISABLE'].present?
    begin
      tweet = @@twitter_client.update(to_twitter_safe(message), in_reply_to_status_id: recruitment.tweet_id)
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
    return ret
  end
end
