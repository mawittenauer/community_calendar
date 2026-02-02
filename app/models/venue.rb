class Venue < ApplicationRecord
  has_many :events, dependent: :restrict_with_error

  validates :name, presence: true

  def full_address
    parts = [address1, address2, city, state, postal_code].compact_blank
    parts.join(", ")
  end
end
