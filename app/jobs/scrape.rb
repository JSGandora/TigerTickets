#!/usr/bin/env ruby

require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
include Capybara::DSL
require 'phantomjs'

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
     event_nodes = session.all(".result-box-item")
     
     for event in event_nodes
          events.append(event.text)
     end
     
     # Click on next page
     if i != num_events
          session.all('#av-prev-link a')[-1].click
     end
end

events.each do |x|
     print x + "\n"
end