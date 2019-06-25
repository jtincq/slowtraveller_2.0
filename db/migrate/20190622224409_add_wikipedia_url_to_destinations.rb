class AddWikipediaUrlToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_column :destinations, :wikipedia_url, :string
  end
end
