class DropTablesToDestinations < ActiveRecord::Migration[5.2]
  def change
    remove_column :destinations, :category
    remove_column :destinations, :photo_medium_four
  end
end
