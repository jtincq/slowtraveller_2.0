class AddColumnsToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_column :destinations, :photo_medium_one, :string
    add_column :destinations, :photo_medium_two, :string
    add_column :destinations, :photo_medium_three, :string
    add_column :destinations, :photo_medium_four, :string
    add_column :destinations, :long_description, :string
    add_column :destinations, :url_destination, :string
    remove_column :destinations, :photo_medium
    change_column :destinations, :score, :float
  end
end
