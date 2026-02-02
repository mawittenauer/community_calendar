class EventTag < ApplicationRecord
  belongs_to :event
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :event_id }
end
