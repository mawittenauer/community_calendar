class CreateVenues < ActiveRecord::Migration[8.0]
  def change
    create_table :venues do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :postal_code
      t.text :notes
      t.string :map_url

      t.timestamps
    end
  end
end
