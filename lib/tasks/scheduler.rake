desc "Scrapes ticketing website and updates database"
task :scrape_tickets => :environment do
  Show.scrape
end