class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :slug
      t.boolean :is_active

      t.timestamps
    end
  end
end
