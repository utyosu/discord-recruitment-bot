require 'http'
module Api
  extend self
  BASE_URI = "http://localhost:3000/api"

  def check_response(response)
    raise Api::InvalidStatusError.new("サーバでエラーが発生しました。時間をおいても改善しない場合は管理者にご連絡下さい。") if response.status == 500
    return response
  end

  class Recruitment
    def self.index
      Api.check_response HTTP.get("#{BASE_URI}/recruitments")
    end

    def self.create(content, expired_at)
      Api.check_response HTTP.post("#{BASE_URI}/recruitments", params: {"recruitment[content]": content, "recruitment[expired_at]": expired_at.to_s})
    end

    def self.destroy(id)
      Api.check_response HTTP.delete("#{BASE_URI}/recruitments/#{id}")
    end
  end

  class Participant
    def self.join(recruitment_id, participant)
      Api.check_response HTTP.post("#{BASE_URI}/recruitments/#{recruitment_id}/participants", params: {"participant[name]": participant.username, "participant[discord_id]": participant.id})
    end

    def self.leave(recruitment_id, participant_id)
      Api.check_response HTTP.delete("#{BASE_URI}/recruitments/#{recruitment_id}/participants/#{participant_id}")
    end
  end

  class Interaction
    def self.create(keyword, response, registered_user)
      Api.check_response HTTP.post("#{BASE_URI}/interactions", params: {"interaction[keyword]": keyword, "interaction[response]": response, "interaction[registered_user_name]": registered_user.username, "interaction[registered_user_discord_id]": registered_user.id})
    end

    def self.destroy(keyword)
      Api.check_response HTTP.delete("#{BASE_URI}/interactions/destroy_by_keyword", params: {"keyword": keyword})
    end

    def self.search(keyword)
      Api.check_response HTTP.get("#{BASE_URI}/interactions/search", params: {"keyword": keyword})
    end
  end

  class InvalidStatusError < StandardError; end
end
