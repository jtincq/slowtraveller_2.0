require 'json'
require 'open-uri'
require_relative 'countries'

puts "Destroy destinations and labels"
Label.destroy_all
Destination.destroy_all

def save_images(destination, destination_created)
  destination["images"].each do |image|
    image_small_url = image['sizes']['thumbnail']['url'] if image["sizes"]["thumbnail"]
    destination_created.photo_small << "{#{image_small_url}}"
    image_medium_url = image["sizes"]["medium"]["url"] if image["sizes"]["medium"]
    destination_created.photo_medium << "{#{image_medium_url}}"
  end
  destination_created.save
end

def find_source_url(destination, destination_created)
  destination["attribution"].each do |attribution|
    if attribution["source_id"] == "wikipedia"
      destination_created.wikipedia_url = attribution["url"]
      destination_created.save
    end
  end
end

def create_destinations(destination)
  destination_created = Destination.create!(
  name: destination["name"],
  description: destination["snippet"],
  score: destination["score"],
  lat: destination["coordinates"]["latitude"],
  lng: destination["coordinates"]["longitude"],
  country: destination["country_id"].split("_").join(" "),
  )
  find_source_url(destination, destination_created)
  save_images(destination, destination_created)
end

def parsing(url)
  dest_json = open(url).read
  JSON.parse(dest_json)["results"]
end

def create_city_destination(country)
  puts "Creating destinations for #{country}"
  url =  "https://www.triposo.com/api/20181213/location.json?part_of=#{country}&tag_labels=city&count=30&order_by=-score&fields=name,coordinates,snippet,country_id,score,type,images,attribution#{ENV['TRIPOSO_API_KEY']}"
  destinations = parsing(url)
  destinations.each do |destination|
    create_destinations(destination)
  end
end

puts "Creating destinations for islands"
islands = parsing("https://www.triposo.com/api/20181213/location.json?type=island&count=100&order_by=-score#{ENV['TRIPOSO_API_KEY']}")
islands.each do |island|
  create_destinations(island)
end

puts "Create label 'island' for the islands' destination"
Destination.all.each do |dest|
  Label.create!(
    destination_id: dest.id,
    tag: "island",
    score: dest.score
  )
end

puts "Creating individual destinations"
[
  "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Hong_Kong&trigram=%3E=0.3&count=1#{ENV['TRIPOSO_API_KEY']}",
  "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Singapore&trigram=%3E=0.3&count=1#{ENV['TRIPOSO_API_KEY']}",
  "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Macau&trigram=%3E=0.3&count=1#{ENV['TRIPOSO_API_KEY']}",
  "https://www.triposo.com/api/20181213/location.json?annotate=trigram:San_Marino&trigram=%3E=0.3&type=city_state#{ENV['TRIPOSO_API_KEY']}",
  "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Beijing&trigram=>=0.3#{ENV['TRIPOSO_API_KEY']}",
  "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Shanghai&trigram=>=0.3#{ENV['TRIPOSO_API_KEY']}"
].each do |url|
  city = parsing(url).first
  create_destinations(city)
end

COUNTRIES.sort.each do |country|
  create_city_destination(country)
end

# Modify encoded name into a more readable or actual version
country_name = ["Georgia", "China", "Réunion", "São Tomé and Príncipe", "Saint-Barthélemy", "Myanmar", "Côte d'Ivoire"]
["Georgia 28country29",
"People27s Republic of China",
"RC3A9union", "SC3A3o TomC3A9 and PrC3ADncipe",
"Saint BarthC3A9lemy",
"Burma",
"CC3B4te d27Ivoire"].each_with_index do |c, i|
  dest = Destination.where("country = ?", c)
  dest.each do |d|
    d.country = country_name[i]
    d.save
  end
end

