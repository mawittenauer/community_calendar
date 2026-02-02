class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :all_day
      t.integer :status
      t.string :source
      t.string :external_url
      t.string :location_override
      t.datetime :last_updated_at
      t.references :category, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true

      t.timestamps
    end
  end
end
