class Recruitment < ApplicationRecord
  has_many :participants, -> {order "created_at ASC"}, dependent: :destroy
  validates :content, presence: true
  before_create :set_label_id

  def set_label_id
    label_ids = Recruitment.where(enable: true).map{|r|r.label_id}
    id = 1
    while(label_ids.include?(id)) do
      id += 1
    end
    self.label_id = id
  end

  def author_discord_id
    participants.empty? ? nil : participants.first.discord_id
  end
end
