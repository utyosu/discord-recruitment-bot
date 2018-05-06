class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :recruitment
  validates :recruitment_id, presence: true
end
