require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
require 'phantomjs'
require 'time'

#rails r app/models/mccarterTheatre.rb
begin
# Visit website
session = Capybara::Session.new(:poltergeist)
session.visit("http://www.mccarter.org/TicketOffice/seasonoverview.aspx?page_id=97")
# Link no longer exists!!!
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
	 	zone = "Eastern Time (US & Canada)"
        t = ActiveSupport::TimeZone[zone].parse(d.text)
        Show.create(title: showTitle[i], time: t, location: "McCarter Theatre Center", group: groupName[i], img: pictureURLs[i])
	end
end
rescue
    puts "The University Season at McCarter Theatre has not begun."
end

