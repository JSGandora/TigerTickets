require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
require 'phantomjs'
require 'time'
class Show < ApplicationRecord
     validates :title, uniqueness: {scope: [:time, :location, :group]}
     
     def self.scrape
          # Event Attributes (fill with the css strings of the child nodes)
          css_strings = ['.item-name', '.item-venue', '.item-teaser', '.start-date']
          
          # Visit website
          session = Capybara::Session.new(:poltergeist)
          session.visit("https://tickets.princeton.edu/Online/")
          
          # Parse number of pages
          num_pages = session.all('.av-paging-links')[-1].text.to_i
          
          # All events
          events = []
          
          # Navigate tickets
          for i in 1..num_pages
               # Parse event info
               event_nodes = session.all(".result-box-item")[0...-1]
               
               for event in event_nodes
                    event_data = Hash.new
                    # For each attribute, check if it exists
                    css_strings.each do |child_css|
                         if event.has_css?(child_css)
                              event_data[child_css] = event.find(child_css).text
                         else
                              event_data[child_css] = ""
                         end
                    end
                    events.append(event_data)
               end
               
               # Click on next page
               if i != num_pages
                    session.all('#av-prev-link a')[-1].click
               end
          end
          
          events.each do |e|
               name = e[".item-name"]
               venue = e['.item-venue']
               description = e['.item-teaser']
               t = Time.parse(e['.start-date'])
               Show.create(title: name, time: t, location: venue, group: description)
          end
     end
end
