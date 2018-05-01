require 'http'
module Api
  BASE_URI = "http://localhost:3000/api"

  class Recruitment
    def self.index
      response = HTTP.get("#{BASE_URI}/recruitments")
      return JSON.parse(response.body)
    end

    def self.create(content, expired_at)
      response = HTTP.post("#{BASE_URI}/recruitments", params: {"recruitment[content]": content, "recruitment[expired_at]": expired_at.to_s})
      return JSON.parse(response.body)
    end

    def self.destroy(id)
      HTTP.delete("#{BASE_URI}/recruitments/#{id}")
    end
  end

  class Participant
    def self.join(recruitment_id, participant)
      response = HTTP.post("#{BASE_URI}/recruitments/#{recruitment_id}/participants", params: {"participant[name]": participant.username, "participant[discord_id]": participant.id})
      return JSON.parse(response.body)
    end

    def self.leave(recruitment_id, participant_id)
      response = HTTP.delete("#{BASE_URI}/recruitments/#{recruitment_id}/participants/#{participant_id}")
    end
  end

  class Interaction
    def self.create(keyword, response, registered_user)
      response = HTTP.post("#{BASE_URI}/interactions", params: {"interaction[keyword]": keyword, "interaction[response]": response, "interaction[registered_user_name]": registered_user.username, "interaction[registered_user_discord_id]": registered_user.id})
      return JSON.parse(response.body)
    end

    def self.destroy(keyword)
      response = HTTP.delete("#{BASE_URI}/interactions/destroy_by_keyword", params: {"keyword": keyword})
    end

    def self.search(keyword)
      response = HTTP.get("#{BASE_URI}/interactions/search", params: {"keyword": keyword})
      return JSON.parse(response.body)
    end
  end
end
