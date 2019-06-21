require 'json'
require 'open-uri'
require 'nokogiri'

puts "Destroy destinations"
Destination.destroy_all

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

COUNTRIES.each do |country|
  create_destination(country)
end

def url(country)
 "https://www.triposo.com/api/20181213/location.json?part_of=#{country}&tag_labels=city&count=30&order_by=-score&fields=name,coordinates,snippet,country_id,score,type,images#{ENV['TRIPOSO_API_KEY']}"
end

def create_destination(country)
  puts "Creating destinations for #{country}"
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
      # category: destination["type"],
      score: destination["score"],
      latitude: destination["coordinates"]["latitude"],
      longitude: destination["coordinates"]["longitude"],
      country: destination["country_id"].split("_").join(" ")
    )

    url_wikitravel = destination["attribution"][0]["url"]
    destination_created.long_description = scrape_long_description(url_wikitravel)
    destination_created.url_destination = scrape_link_destination_website(url_wikitravel)
    destination_created.save
    raise
  end

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
end

