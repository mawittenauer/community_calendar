class Event < ApplicationRecord
  belongs_to :category
  belongs_to :venue, optional: true

  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags

  enum :status, [:scheduled, :canceled, :postponed]

  validates :title, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_after_start

  before_save :touch_last_updated_at

  scope :between, ->(start_time, end_time) { where("start_at < ? AND end_at > ?", end_time, start_time) }
  scope :with_status, ->(s) { where(status: statuses[s]) if s.present? }
  scope :search, ->(q) {
    return all if q.blank?
    where("title ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(q)}%")
  }

  private

  def end_after_start
    return if start_at.blank? || end_at.blank?
    errors.add(:end_at, "must be after start time") if end_at <= start_at
  end

  def touch_last_updated_at
    self.last_updated_at = Time.current
  end
end
