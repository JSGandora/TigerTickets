require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
require 'phantomjs'
require 'time'

class EventScrapeJob < ApplicationJob
  queue_as :default
  
  def parse_event(event)
	name = event.find('.item-name').text
	date = Time.parse(event.find('.start-date').text).to_s
	loc = event.find('.item-venue').text
	info = event.find('.item-teaser').text
	print name, date, loc, info
	print event.text
  end
  
  def perform(*args)
	session = Capybara::Session.new(:poltergeist)

	# Visit website
	session.visit("https://tickets.princeton.edu/Online/")
	
	# Parse number of pages
	num_events = session.all('.av-paging-links')[-1].text.to_i
	
	# All events
	events = []
	
	# Navigate tickets
	for i in 1..num_events
	  # Parse event info
	  events += session.all(".result-box-item")[0...-1]
	  
	  # Click on next page
	  if i != num_events
		  session.all('#av-prev-link a')[-1].click
	  end
	end
	
	print events
  end
end
