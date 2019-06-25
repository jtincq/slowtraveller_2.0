# Create a list of countries based on the api Triposo's list of countries
require 'json'
require 'open-uri'

puts "Create countries"

def scraping(url)
  countries_json = open(url).read
  JSON.parse(countries_json)["results"]
end

COUNTRIES = []
urls = ["https://www.triposo.com/api/20181213/location.json?type=country&order_by=-score&fields=country_id,score&count=100#{ENV['TRIPOSO_API_KEY']}",
        "https://www.triposo.com/api/20181213/location.json?type=country&order_by=score&fields=country_id,score&count=100#{ENV['TRIPOSO_API_KEY']}",
        "https://www.triposo.com/api/20181213/location.json?type=country&order_by=-name&fields=country_id,score&count=100#{ENV['TRIPOSO_API_KEY']}",
        "https://www.triposo.com/api/20181213/location.json?type=country&order_by=name&fields=country_id,score&count=100#{ENV['TRIPOSO_API_KEY']}"]
urls.each do |url|
  scraping(url).each do |country|
    COUNTRIES << country["country_id"] unless COUNTRIES.include?(country["country_id"])
  end
end

["Guernsey", "Lebanon", "Lesotho", "Malaysia"].each do |c|
  COUNTRIES << c
end

COUNTRIES
