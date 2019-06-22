require 'json'
require 'open-uri'
require 'nokogiri'
require_relative 'countries'

puts "Destroy destinations"
Destination.destroy_all

def scrape_wikitravel(url)
  html_file = open(url).read
  Nokogiri::HTML(html_file)
end

def scrape_long_description(url)
  html_doc = scrape_wikitravel(url)

  desc = html_doc.search('.mw-parser-output p').first
  desc.text.strip unless desc.nil?
end

def scrape_link_destination_website(url)
  html_doc = scrape_wikitravel(url)

  link = html_doc.search('.mw-parser-output p b a').first
  link_attribute = link.attribute('href') unless link.nil?
  link_attribute.value unless link_attribute.nil?
end

# Create labels for each destinations

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

def create_destinations(destination)
  destination_created = Destination.create!(
  name: destination["name"],
  description: destination["snippet"],
  photo_medium_one: destination["images"][0]["sizes"]["medium"]["url"],
  photo_small: destination["images"][0]["sizes"]["thumbnail"]["url"],
  score: destination["score"],
  lat: destination["coordinates"]["latitude"],
  lng: destination["coordinates"]["longitude"],
  country: destination["country_id"].split("_").join(" ")
  )

  destination_created.photo_medium_two = destination["images"][1]["sizes"]["medium"]["url"] if destination["images"].size > 1

  destination_created.photo_medium_three = destination["images"][2]["sizes"]["medium"]["url"] if destination["images"].size > 2
  url_wikitravel = destination["attribution"][0]["url"]
  destination_created.long_description = scrape_long_description(url_wikitravel)
  destination_created.url_destination = scrape_link_destination_website(url_wikitravel)
  destination_created.save

  create_label_for_destination(destination_created)
end

def parsing(url)
  dest_json = open(url).read
  JSON.parse(dest_json)["results"]
end

count = 0
def create_city_destination(country)
  count += 1
  puts "Creating destinations for #{country} - #{count}"
  url =  "https://www.triposo.com/api/20181213/location.json?part_of=#{country}&tag_labels=city&count=30&order_by=-score&fields=name,coordinates,snippet,country_id,score,type,images,attribution#{ENV['TRIPOSO_API_KEY']}"
  destinations = parsing(url)
  destinations.each do |destination|
    create_destinations(destination)
  end
end

# puts "Creating destinations for islands"
# islands = parsing("https://www.triposo.com/api/20181213/location.json?type=island&count=100&order_by=-score#{ENV['TRIPOSO_API_KEY']}")
# islands.each do |island|
#   create_destinations(island)
# end

# puts "Creating individual destinations"
# [
#   "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Hong_Kong&trigram=%3E=0.3&count=1#{ENV['TRIPOSO_API_KEY']}",
#   "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Singapore&trigram=%3E=0.3&count=1#{ENV['TRIPOSO_API_KEY']}",
#   "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Macau&trigram=%3E=0.3&count=1#{ENV['TRIPOSO_API_KEY']}",
#   "https://www.triposo.com/api/20181213/location.json?annotate=trigram:San_Marino&trigram=%3E=0.3&type=city_state#{ENV['TRIPOSO_API_KEY']}",
#   "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Beijing&trigram=>=0.3#{ENV['TRIPOSO_API_KEY']}",
#   "https://www.triposo.com/api/20181213/location.json?annotate=trigram:Shanghai&trigram=>=0.3#{ENV['TRIPOSO_API_KEY']}"
# ].each do |url|
#   city = parsing(url).first
#   create_destinations(city)
# end


# Scraping longer description and destination's touristic website from wikitravel
COUNTRIES.each do |country|
  create_city_destination(country)
end

country_name = ["Georgia", "China", "Réunion", "São Tomé and Príncipe", "Saint-Barthélemy", "Myanmar"]
["Georgia_28country29", "People27s_Republic_of_China", "RC3A9union", "SC3A3o_TomC3A9_and_PrC3ADncipe", "Saint_BarthC3A9lemy", "Burma"],each_with_index do |c, i|
  dest = Destination.where("country = ?", c)
  dest.country = country_name[i]
  dest.save
end

