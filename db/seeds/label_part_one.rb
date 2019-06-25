# Create labels for each destination
require 'json'
require 'open-uri'

puts "Destroy labels for destinations 1 to 1500"
id_first = Label.first.id
id_last = id_first + 1499
Label.where(id: id_first..id_last).destroy_all

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

puts "Create label for destinations 1 to 1500"

count = 0

puts "First round"
Destination.all[0..1500].each do |dest|
  puts count
  create_label_for_destination(dest)
  count += 1
end

puts "Wait 1 hour before rake next label seed"
puts Time.now
