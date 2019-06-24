# Create labels for each destination
require 'json'
require 'open-uri'

def create_label_for_destination(destination)
  tags = ["sightseeing", "exploringnature", "museums", "nightlife", "musicandshows", "beaches"]
  url = "https://www.triposo.com/api/20181213/tag.json?location_id=#{URI.encode(destination.name.split(" ").join("_"))}&count=100&fields=label,score#{ENV['TRIPOSO_API_KEY']}"
  labels_json = open(url).read
  labels = JSON.parse(labels_json)["results"]

  labels.each do |label|
    if tags.include?(label["label"]) && label["score"] > 5
      Label.create!(
        destination_id: destination.id,
        tag: label["label"],
        score: label["score"]
      )
    end
  end
end

puts "Create label for each destination"

count = 0
Destination.all.each do |dest|
  puts count
  create_label_for_destination(dest)
  count += 1
end
