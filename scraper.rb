require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  url = "https://blockwork.cc/"
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)
  jobs = []
  job_listings = parsed_page.css('div.listingCard')
  
  page = 1
  per_page = job_listings.count
  total = parsed_page.css('div.job-count').text.split(' ')[1].gsub(',','').to_i
  last_page = (total.to_f / per_page.to_f).round
  while page <= last_page
    pagination_url = "https://blockwork.cc/listings?page=#{page}"
    puts pagination_url
    puts "Page: #{page}"
    puts ""

    pagination_unparsed_page = HTTParty.get(pagination_url)
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_job_listings = pagination_parsed_page.css('div.listingCard')
    
    pagination_job_listings.each do |job_listing|
      job = {
        title: job_listing.css('span.job-title').text,
        company: job_listing.css('span.company').text,
        location: job_listing.css('span.location').text,
        url: "https://blockwork.cc" + job_listing.css('a')[0].attributes["href"].value
      }
      jobs << job
      puts ">>>>>> Added #{job[:title]}"
      puts ""
    end
    page += 1
  end
end

scraper