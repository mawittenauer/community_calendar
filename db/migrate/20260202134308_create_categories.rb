class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :sort_order
      t.boolean :is_active

      t.timestamps
    end
  end
end
