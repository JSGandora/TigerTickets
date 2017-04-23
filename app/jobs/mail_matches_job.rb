require 'sendgrid-ruby'
include SendGrid
class MailMatchesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    recipientsInfo = args[0]
    show = args[1]
    email = args[2]
    
    # Get recipients
    to = []
    recipientsInfo.each do |label, recipient|
      to << {"email": recipient[:email]}
    end
    
    puts "**************EMAIL RECIPIENTS**************"
    puts to

    timeString = show.time.in_time_zone("America/New_York").strftime('%B %d, %Y %l:%M %p')
    showTitle = show.title

    # Create content
    content = "<p>You've been matched for the following show:</p><p>Show Details:</p>"
    content += "<p>#{showTitle} at #{timeString}</p>"
    recipientsInfo.each do |label, recipient|
      role = recipient[:role]
      email = recipient[:email]
      content += "<p>#{role}: #{email}</p>"
    end
    
    puts "**************EMAIL BODY********************"
    puts content
    
    buyerNetId = recipientsInfo[:buying][:netid]

    data = {
      "personalizations": [
        {
          "to": to,
          "subject": "#{buyerNetId} is a new buyer for #{showTitle}"
        }
      ],
      "from": {
        "email": "No-Reply-Tiger-Tickets@princeton.edu",
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
    if response.status_code.to_i == 202
      email.update(status: "sent")
    else
      email.update(status: "failed")
    end
    puts response.body
    puts response.headers
  end
end
