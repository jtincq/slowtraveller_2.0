require 'json'
require 'open-uri'
require 'nokogiri'

puts "Destroy destinations"
Destination.destroy_all

create_island_destination

def create_city_destination(country)
  puts "Creating destinations for #{country}"
  url =  "https://www.triposo.com/api/20181213/location.json?part_of=#{country}&tag_labels=city&count=30&order_by=-score&fields=name,coordinates,snippet,country_id,score,type,images#{ENV['TRIPOSO_API_KEY']}"
  destinations_json = open(url(country)).read
  destinations = JSON.parse(destinations_json)["results"]
  destinations.each do |destination|
    destination_created = Destination.create!(
      name: destination["name"],
      description: destination["snippet"],
      photo_medium_one: destination["images"][0]["sizes"]["medium"]["url"],
      photo_medium_two: destination["images"][1]["sizes"]["medium"]["url"],
      photo_medium_three: destination["images"][2]["sizes"]["medium"]["url"],
      photo_medium_four: destination["images"][3]["sizes"]["medium"]["url"],
      photo_small: destination["images"][0]["sizes"]["thumbnail"]["url"],
      score: destination["score"],
      latitude: destination["coordinates"]["latitude"],
      longitude: destination["coordinates"]["longitude"],
      country: destination["country_id"].split("_").join(" ")
    )

    url_wikitravel = destination["attribution"][0]["url"]
    destination_created.long_description = scrape_long_description(url_wikitravel)
    destination_created.url_destination = scrape_link_destination_website(url_wikitravel)
    destination_created.save

    create_label_for_destination(destination_created)
    raise
  end
end

def create_island_destination
  puts "Creating destinations for islands"
  islands_json = open("https://www.triposo.com/api/20181213/location.json?type=island#{ENV['TRIPOSO_API_KEY']}").read
  islands = JSON.parse(islands_json)["results"]
  islands.each do |island|
    island_created = Destination.create!(
    name: island["name"],
    description: island["snippet"],
    photo_medium_one: island["images"][0]["sizes"]["medium"]["url"],
    photo_medium_two: island["images"][1]["sizes"]["medium"]["url"],
    photo_medium_three: island["images"][2]["sizes"]["medium"]["url"],
    photo_medium_four: island["images"][3]["sizes"]["medium"]["url"],
    photo_small: island["images"][0]["sizes"]["thumbnail"]["url"],
    score: island["score"],
    latitude: island["coordinates"]["latitude"],
    longitude: island["coordinates"]["longitude"],
    country: island["country_id"].split("_").join(" ")
  )

  url_wikitravel = island["attribution"][0]["url"]
  island_created.long_description = scrape_long_description(url_wikitravel)
  island_created.url_destination = scrape_link_destination_website(url_wikitravel)
  island_created.save

  create_label_for_destination(island_created)

  Label.create!(
    destination_id: island_created.id,
    tag: "island",
    score_tag: island["score"]
  )
  end
end

private

  # Scraping longer description and destination's touristic website from wikitravel

def scrape_wikitravel(url)
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)
end

def scrape_long_description(url)
  scrape_wikitravel(url)

  html_doc.search('.mw-parser-output p').first.text.strip
end

def scrape_link_destination_website(url)
  scrape_wikitravel(url)

  html_doc.search('.mw-parser-output p b a').first.attribute('href').value
end

# ---------------------CREATE LABELS FOR EACH DESTINATION-----------------------
tags = ["sightseeing", "exploringnature", "museums", "nightlife", "musicandshows", "beaches"]

def create_label_for_destination(destination)
  url = "https://www.triposo.com/api/20181213/tag.json?location_id=#{destination}&count=100&fields=label,score#{ENV['TRIPOSO_API_KEY']}"
  labels_json = open(url).read
  labels = JSON.parse(labels_json)["results"]

  labels.each do |label|
    if tags.include(label["label"]) && label["score"] > 5
      Label.create!(
        destination_id: destination.id,
        tag: label["label"],
        score_tag: label["score"]
      )
    end
  end

  # list of countries from the api triposo

def get_countries
  countries_array = []
  countries_json = open("https://www.triposo.com/api/20181213/location.json?type=country#{ENV['TRIPOSO_API_KEY']}")
  countries = JSON.parse(countries_json)["results"]
  countries.each do |country|
    countries_array << country["country_id"]
  end
  countries_array
end

COUNTRIES = get_countries

# Create destinations for each country
COUNTRIES.each do |country|
  create_city_destination(country)
end
end

