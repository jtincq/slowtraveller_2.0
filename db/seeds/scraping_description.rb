# task to fetch longer description and a travel destination's url for each Destination
require 'open-uri'
require 'nokogiri'


def scrape_wikitravel(url)
  html_file = open(url).read
  Nokogiri::HTML(html_file)
end

def scrape_long_description(url)
  html_doc = scrape_wikitravel(url)

  desc = html_doc.search('.mw-parser-output p').first(2)
  description_array = []
  desc.each do |d|
    description_array << d.text.strip unless d.nil?
  end

  description_array.delete_if { |i| i == " " || i == "" }

  if description_array.size > 1
    description_array.join("\n")
  else
    description_array.join
  end
end

puts "Scraping url and longer description"

puts Time.now
Destination.all.each do |dest|
  dest.long_description = scrape_long_description(dest.wikipedia_url)
  dest.save
end
puts Time.now
