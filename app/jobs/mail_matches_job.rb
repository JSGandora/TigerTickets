require 'sendgrid-ruby'
include SendGrid
class MailMatchesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    
    recipients = args[0]
    show = args[1]
    
    # Get recipients
    to = []
    recipients.each do |recipient|
      to << {"email": recipient[0]}
    end
    
    puts "**************EMAIL RECIPIENTS**************"
    puts to
    timeString = show.time.in_time_zone("America/New_York").strftime('%B %d, %Y %l:%M %p')
    # Create content
    content = "<p>You've been matched for the following show:</p><p>Show Details:</p>"
    content += "<p>#{show.title} at #{timeString}</p>"
    recipients.each do |recipient|
      content += "<p>#{recipient[1]}: #{recipient[0]}</p>"
    end
    
    puts "**************EMAIL BODY********************"
    puts content
    
    data = {
      "personalizations": [
        {
          "to": to,
          "subject": "You've been matched!"
        }
      ],
      "from": {
        "email": "Tiger-Tickets@princeton.edu",
        "name": "Tiger Tickets!"
      },
      "content": [
        {
          "type": "text/html",
          "value": content
        }
      ]
    }
    
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
