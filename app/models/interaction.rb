class Interaction < ApplicationRecord
  belongs_to :user
  validates :keyword, presence: true
  validates :response, presence: true
end
