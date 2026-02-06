json.extract! event, :id, :title, :description, :start_at, :end_at, :all_day, :status, :source, :external_url, :location_override, :category_id, :venue_id, :created_at, :updated_at
json.url admin_event_url(event, format: :json)
