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
end
