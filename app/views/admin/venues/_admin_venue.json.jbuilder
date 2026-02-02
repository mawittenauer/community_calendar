json.extract! admin_venue, :id, :name, :address1, :address2, :city, :state, :postal_code, :notes, :map_url, :created_at, :updated_at
json.url admin_venue_url(admin_venue, format: :json)
