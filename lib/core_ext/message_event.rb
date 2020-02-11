module Discordrb
  module Events
    class MessageEvent < Event
      delegate :pm?, to: :channel

      def play?
        channel.id == Settings.secret.discord.play_channel_id.to_i
      end

      def recruitment?
        channel.id == Settings.secret.discord.recruitment_channel_id.to_i
      end

      def match_any_keywords?(keywords)
        content = Helper.to_safe(Helper.get_message_content(self))
        keywords.any? { |keyword| content.match?(Regexp.new(keyword)) }
      end
    end
  end
end
