class AddConstraintsAndIndexes < ActiveRecord::Migration[7.1]
  def change
    # Defaults
    change_column_default :categories, :is_active, from: nil, to: true
    change_column_default :tags, :is_active, from: nil, to: true
    change_column_default :events, :all_day, from: nil, to: false
    change_column_default :events, :status, from: nil, to: 0

    # Null constraints
    change_column_null :categories, :name, false
    change_column_null :categories, :slug, false
    change_column_null :tags, :name, false
    change_column_null :tags, :slug, false

    change_column_null :events, :title, false
    change_column_null :events, :start_at, false
    change_column_null :events, :end_at, false
    change_column_null :events, :category_id, false

    # Uniqueness
    add_index :categories, :slug, unique: true
    add_index :tags, :slug, unique: true

    add_index :event_tags, [:event_id, :tag_id], unique: true
  end
end
