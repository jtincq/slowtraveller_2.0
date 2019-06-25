class DeleteUrlDestinationFromDestinations < ActiveRecord::Migration[5.2]
  def change
    remove_column :destinations, :url_destination
  end
end
