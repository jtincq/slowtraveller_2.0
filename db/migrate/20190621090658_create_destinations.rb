class CreateDestinations < ActiveRecord::Migration[5.2]
  def change
    create_table :destinations do |t|
      t.string :name
      t.string :description
      t.string :country
      t.string :photo_small
      t.string :photo_medium
      t.string :category
      t.integer :score
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
