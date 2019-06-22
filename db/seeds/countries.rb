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

["Guernsey", "Lebanon", "Lesotho", "Malaysia", "Turks_and_Caicos_Islands"].each do |c|
  COUNTRIES << c
end

COUNTRIES
puts COUNTRIES.count
# Georgia --> renommée parce que s'appelle Georgia_28country29
# China --> renommée parce que s'appelle People27s_Republic_of_China
# Réunion --> renommée parce que s'appelle RC3A9union
# Sao Tome and Principe --> renommée parce que 'sappelle SC3A3o_TomC3A9_and_PrC3ADncipe
# Saint Barthelemy --> renommée parce que s'appelle Saint_BarthC3A9lemy
# Burma --> ajouter (Myanmar)
