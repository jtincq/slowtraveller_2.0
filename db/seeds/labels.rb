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

Destination.all[0..1500].each do |dest|
  puts "First round"
  puts count
  create_label_for_destination(dest)
  count += 1
end

sleep 30 # need a break to avoid error 429

Destination.all[1501..3000].each do |dest|
  puts "Second round"
  puts count
  create_label_for_destination(dest)
  count += 1
end

sleep 30 # need a break to avoid error 429

Destination.all[3001..-1].each do |dest|
  puts "Third round"
  puts count
  create_label_for_destination(dest)
  count += 1
end
