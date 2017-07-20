require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
require 'phantomjs'
require 'time'
class Show < ApplicationRecord
     has_many :sell_requests, :dependent => :delete_all
     has_many :buy_requests, :dependent => :delete_all
     validates :title, uniqueness: {scope: [:time, :location, :group]}
     
     # ALEXS SCRAPERRRRRR
     def self.scrape_mccarter
          begin
               # Visit website
               session = Capybara::Session.new(:poltergeist)
               session.visit("http://www.mccarter.org/TicketOffice/seasonoverview.aspx?page_id=97")
     
               # When this fails the whole scraper will crash. I am adding a begin rescue to fix this.
               session.find("a", :text => "University Season").click
     
               #access the table that holds all of the events
               bigTable = session.first("table > tbody > tr:nth-child(5) > td:nth-child(2) > table > tbody > tr:nth-child(5) > td > table > tbody")
     
               allEvents = bigTable.all("tr")
     
               showURLs = []
     
               #save all the show URLs
               (0..allEvents.size-1).step(2).each do |i|
                    showURLs << allEvents[i].first("a")["href"]
               end
     
               numUniqueShows = showURLs.length
     
               #link to the image of the show
               pictureURLs  = []
     
               #links to the dates of the different shows
               showDateURLs = []
     
               #names of each show
               groupName = []
     
               #title of each show
               showTitle = []
     
     
               (0..numUniqueShows-1).each do |i|
                    session.visit(showURLs[i])
                    #go to page with pictures and links
                    showDateURLs << session.first("#ctl00_center_aPerfs")["href"]
                    pictureURLs << session.first("#ctl00_center_eImg")["src"]
     
                    groupName << session.find(".heading5").text
                    #puts groupName[i].text
     
                    #on page with all show times
                    session.visit(showDateURLs[i])
                    showTable = session.find_by_id("perfDates")
     
                    showTitle << session.find_by_id("prodTitle").text
     
                    info = showTable.all("tr")
                    info.each do |d|
                         buy_link = d.find(".performance_onsale")["href"]
                         zone = "Eastern Time (US & Canada)"
                         t = ActiveSupport::TimeZone[zone].parse(d.text)
                         #Show.create(title: showTitle[i], time: t, location: "McCarter Theatre Center", group: groupName[i], img: pictureURLs[i], buy_link: buy_link)
                         show = Show.where(title: showTitle[i]).where(time: t).where(group: groupName[i]).where(location: "McCarter Theatre Center").first_or_initialize
                         show.title = showTitle[i]
                         show.time = t
                         show.group = groupName[i]
                         show.location = "McCarter Theatre Center"
                         show.img = pictureURLs[i]
                         show.buy_link = buy_link
                         show.website = "McCarter"
                         show.website_id = SecureRandom.uuid
                         show.save
                    end
               end
          rescue
               puts "The University Season at McCarter Theatre has not begun."
          end
     end

     #Richard's SCRAPPPPPEEEEEE
     def self.scrape_frist
          # Event Attributes (fill with the css strings of the child nodes)
          css_strings = ['.item-name', '.item-venue', '.item-teaser', '.start-date']
          img_css = '.item-logo img'
          # Visit website
          session = Capybara::Session.new(:poltergeist)
          session.visit("https://tickets.princeton.edu/Online/")
          
          # Parse number of pages
          num_pages = session.all('.av-paging-links')[-1].text.to_i
          
          # All events
          events = []
          
          # Navigate tickets
          for i in 1..num_pages
               # Parse show information
               articleContext = session.evaluate_script("articleContext")

               # Parse event info
               event_nodes = session.all(".result-box-item")[0...-1]
               
               event_nodes.each_with_index do |event, index|
                    event_data = Hash.new
                    
                    # Get event ID
                    id = articleContext["searchResults"][index][0]
                    event_data['id'] = id
                    
                    # For each attribute, check if it exists
                    css_strings.each do |child_css|
                         if event.has_css?(child_css)
                              event_data[child_css] = event.find(child_css).text
                         else
                              event_data[child_css] = ""
                         end
                    end
                    
                    # Get image url
                    if event.has_css?(img_css)
                         event_data[img_css] = event.find(img_css)[:src]
                    else
                         event_data[img_css] = ""
                    end
                    if event.has_css?('.soldout') === false and event.has_css?('.limited') === false
                         event_data['soldout'] = false
                         event_data['buy_link'] = "https://tickets.princeton.edu/Online/"
                    else
                         event_data['soldout'] = true
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
               zone = "Eastern Time (US & Canada)"
               t = ActiveSupport::TimeZone[zone].parse(e['.start-date'])
               image_url = e[img_css]
               soldout = e['soldout']
               buy_link = e['buy_link']
               id = e['id']
               #Show.create(title: name, time: t, location: venue, group: description, img: image_url, soldout: soldout, buy_link: buy_link)
               show = Show.where(title: name).where(time: t).where(group: description).where(location: venue).first_or_initialize
               show.title = name
               show.time = t
               show.group = description
               show.location = venue
               show.img = image_url
               show.buy_link = buy_link
               show.soldout = soldout
               show.website = "Frist"
               show.website_id = id
               show.save
          end
     end
end
