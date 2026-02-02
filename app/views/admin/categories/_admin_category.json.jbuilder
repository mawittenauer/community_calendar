json.extract! admin_category, :id, :name, :slug, :description, :sort_order, :is_active, :created_at, :updated_at
json.url admin_category_url(admin_category, format: :json)
