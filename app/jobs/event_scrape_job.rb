require 'capybara'
require 'capybara/poltergeist'
Capybara.default_driver = :poltergeist

class EventScrapeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    visit "http://ngauthier.com/"
    all(".posts .post").each do |post|
      title = post.find("h3 a").text
      url   = post.find("h3 a")["href"]
      date  = post.find("h3 small").text
      summary = post.find("p.preview").text
    
      puts title
      puts url
      puts date
      puts summary
      puts ""
    end
  end
end
