class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :events, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(Arel.sql("sort_order NULLS LAST"), :name) }

  # If name changes, regenerate slug
  def should_generate_new_friendly_id?
    name_changed?
  end
end
