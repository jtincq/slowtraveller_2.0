# task to fetch longer description and a travel destination's url for each Destination
require 'open-uri'
require 'nokogiri'


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

puts "Scraping url and longer description"

Destination.all.each do |dest|
  dest.long_description = scrape_long_description(dest.wikipedia_url)
  dest.url_destination = scrape_link_destination_website(dest.wikipedia_url)
  dest.save
end
