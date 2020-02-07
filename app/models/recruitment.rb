class Recruitment < ApplicationRecord
  has_many :participants, -> { order "created_at ASC" }, dependent: :destroy, inverse_of: :recruitment
  validates :content, presence: true
  before_create :set_label_id, :set_reserve_at
  scope :active, -> { where(enable: true) }

  def join(user)
    participants.create(user: user)
  end

  def leave(user)
    self.participants.find_by(user: user).destroy
    self.update(enable: false) if self.participants.empty?
  end

  def set_label_id
    label_ids = Recruitment.active.map { |r| r.label_id }
    id = 1
    while label_ids.include?(id) do
      id += 1
    end
    self.label_id = id
  end

  def set_reserve_at
    self.reserve_at = Extractor.extraction_time(self.content)
  end

  def author
    participants.empty? ? nil : participants.first.user
  end

  def full?
    self.participants.size > self.capacity
  end

  def capacity
    Extractor.extraction_recruit_user_count(self.content)
  end

  def reserved
    self.participants.size - 1
  end

  def mentions
    self.participants.map { |p| "<@#{p.user.discord_id}>" }.join(" ")
  end

  def vacant
    self.capacity - self.reserved
  end

  def to_format_string
    result = I18n.t(
      'recruitment.information.base',
      label_id: label_id,
      content: content,
      author_name: author.name,
      reserved: reserved,
      capacity: capacity,
    )
    if participants.size >= 2
      result += "\n" + I18n.t(
        'recruitment.information.participants',
        participants: participants[1..-1].map { |p| p.user.name }.join(', '),
      )
    end
    return result
  end

  def attended?(user)
    self.participants.any? { |p| p.user == user }
  end

  def self.get_by_label_id(label_id)
    Recruitment.active.find_by(label_id: label_id)
  end

  def self.clean_invalid
    Recruitment.active.each do |recruitment|
      recruitment.update(enable: false) if recruitment.participants.empty?
    end
  end
end
