class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :event_tags, dependent: :destroy
  has_many :events, through: :event_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:name) }

  def should_generate_new_friendly_id?
    name_changed?
  end
end
