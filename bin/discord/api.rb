require 'http'
module Api
  extend self
  BASE_URI = "http://localhost:3000/api"

  def check_response(response)
    raise Api::InvalidStatusError.new("サーバでエラーが発生しました。時間をおいても改善しない場合は管理者にご連絡下さい。") if response.status == 500
    return response
  end

  def contained_params(parent, params)
    params.map{|k,v| ["#{parent}[#{k}]", v]}.to_h
  end

  class Recruitment
    def self.index
      Api.check_response HTTP.get("#{BASE_URI}/recruitments")
    end

    def self.create(params)
      Api.check_response HTTP.post("#{BASE_URI}/recruitments", params: Api.contained_params("recruitment", params))
    end

    def self.update(recruitment, params)
      Api.check_response HTTP.patch("#{BASE_URI}/recruitments/#{recruitment['id']}", params: Api.contained_params("recruitment", params))
    end

    def self.destroy(recruitment)
      Api.check_response HTTP.delete("#{BASE_URI}/recruitments/#{recruitment['id']}")
    end
  end

  class Participant
    def self.join(recruitment, params)
      Api.check_response HTTP.post("#{BASE_URI}/recruitments/#{recruitment['id']}/participants", params: Api.contained_params("participant", params))
    end

    def self.leave(recruitment, participant)
      Api.check_response HTTP.delete("#{BASE_URI}/recruitments/#{recruitment['id']}/participants/#{participant['id']}")
    end
  end

  class Interaction
    def self.create(params)
      Api.check_response HTTP.post("#{BASE_URI}/interactions", params: Api.contained_params("interaction", params))
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
