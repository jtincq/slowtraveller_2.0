class ChangePhotoColumnsInDestinations < ActiveRecord::Migration[5.2]
  def change
    remove_column :destinations, :photo_medium_one
    remove_column :destinations, :photo_medium_two
    remove_column :destinations, :photo_medium_three
    remove_column :destinations, :photo_small
    add_column :destinations, :photo_small, :text, array: true, default: []
    add_column :destinations, :photo_medium, :text, array: true, default: []
  end
end
