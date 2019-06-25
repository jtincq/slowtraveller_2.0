require 'json'
require 'open-uri'
require_relative 'countries'

puts "Destroy destinations"
Destination.destroy_all

def save_images(destination, destination_created)
  if destination["images"].size > 2 && destination["images"][2]["sizes"].has_key?("original")
    destination_created.photo_small = destination["images"][0]["sizes"]["thumbnail"]["url"]
    destination_created.photo_medium_one = destination["images"][0]["sizes"]["medium"]["url"]
    destination_created.photo_medium_two = destination["images"][1]["sizes"]["medium"]["url"] unless destination["images"][1]["sizes"]["medium"].nil?
    destination_created.photo_medium_three = destination["images"][2]["sizes"]["medium"]["url"] unless destination["images"][2]["sizes"]["medium"].nil?
    destination_created.save
  elsif destination["images"].size > 1 && destination["images"][1]["sizes"].has_key?("original")
    destination_created.photo_small = destination["images"][0]["sizes"]["thumbnail"]["url"]
    destination_created.photo_medium_one = destination["images"][0]["sizes"]["medium"]["url"]
    destination_created.photo_medium_two = destination["images"][1]["sizes"]["medium"]["url"] unless destination["images"][1]["sizes"]["medium"].nil?
    destination_created.save
  elsif destination["images"].size.positive? && destination["images"][0]["sizes"].has_key?("original")
    destination_created.photo_small = destination["images"][0]["sizes"]["thumbnail"]["url"]
    destination_created.photo_medium_one = destination["images"][0]["sizes"]["medium"]["url"]
    destination_created.save
  else
    puts "No pictures for #{destination_created.name}"
  end
end

def find_source_url(destination, destination_created)
  if destination["attribution"][0]["source_id"] == "wikipedia"
    destination_created.wikipedia_url = destination["attribution"][0]["url"]
    destination_created.save
  elsif destination["attribution"].size > 1 && destination["attribution"][1]["source_id"] == "wikipedia"
    destination_created.wikipedia_url = destination["attribution"][1]["url"]
    destination_created.save
  elsif destination["attribution"].size > 2 && destination["attribution"][2]["source_id"] == "wikipedia"
    destination_created.wikipedia_url = destination["attribution"][2]["url"]
    destination_created.save
  else
    puts "No wiki url for #{destination_created.name}"
  end
end

def create_destinations(destination)
  destination_created = Destination.create!(
  name: destination["name"],
  description: destination["snippet"],
  score: destination["score"],
  lat: destination["coordinates"]["latitude"],
  lng: destination["coordinates"]["longitude"],
  country: destination["country_id"].split("_").join(" ")
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

