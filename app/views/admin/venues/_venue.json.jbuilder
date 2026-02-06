json.extract! venue, :id, :name, :address1, :address2, :city, :state, :postal_code, :notes, :map_url, :created_at, :updated_at
json.url admin_venue_url(venue, format: :json)
