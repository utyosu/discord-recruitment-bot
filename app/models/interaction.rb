class Interaction < ApplicationRecord
  validates :keyword, presence: true
  validates :response, presence: true
end
