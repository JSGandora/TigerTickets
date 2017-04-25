desc "Scrapes ticketing website and updates database"
task :scrape_tickets => :environment do
  Show.scrape_frist
  Show.scrape_mccarter
end