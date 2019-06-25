# Create labels for each destination
require 'json'
require 'open-uri'

puts "Destroy labels for destinations 3001 to last"
first_id = Label.first.id + 3000
last_id = Label.last.id
Label.where(id: first_id..last_id).destroy_all

def create_label_for_destination(destination)
  tags = ["sightseeing", "exploringnature", "museums", "nightlife", "musicandshows", "beaches"]
  url = "https://www.triposo.com/api/20181213/tag.json?location_id=#{URI.encode(destination.name.split(" ").join("_"))}&count=100&fields=label,score#{ENV['TRIPOSO_API_KEY']}"
  labels_json = open(url).read
  labels = JSON.parse(labels_json)["results"]

  labels.each do |label|
    if tags.include?(label["label"]) && label["score"] > 3
      Label.create!(
        destination_id: destination.id,
        tag: label["label"],
        score: label["score"]
      )
    end
  end
end

puts "Create label for destinations 3001 to last"

count = 0

puts "Third round"
Destination.all[3001..-1].each do |dest|
  puts count
  create_label_for_destination(dest)
  count += 1
end
