require 'sendgrid-ruby'
include SendGrid
class MailMatchesJob < ApplicationJob
  queue_as :default

  def perform(*args)

    email = args[0]

    case email.email_type
    when "welcome-seller", "welcome-buyer"
      show = email.show
      showTitle = show.title
      recipient = ""
      subject = ""
      body = ""
      if email.email_type == "welcome-seller"

        recipient = email.sell_request.netid + "@princeton.edu"
        subject += "You now have a sell request in for #{showTitle}"

        body += "<p>You now have a sell request in for:</p>"
        timeString = show.time.in_time_zone("America/New_York").strftime('%B %d, %Y %l:%M %p')
        body += "<p>#{showTitle} at #{timeString}</p>"

        buyRequests = show.buy_requests
        if buyRequests.length == 0
          body += "<p>There are currnetly no buyers for this ticket, but we will let you know as soon as somebody puts up a buy request.</p>"
        else
          body += "<p>Here are the people interested in buying this ticket:</p>"

          buyRequests.each do |buyRequest|
            netid = buyRequest.netid
            body += "netid: #{netid}, email: #{netid}@princeton.edu <br />"
          end
          body += "<p>We have sent them emails, and they should contact you with when they can pick up your ticket.</p>"

        end
        body += "Once you have made an arrangment with someone, simply click the button below to stop recieving notifications. You can also change the status of your request on the <a href='tiger-tickets.herokuapp.com/my-tix'>my-tix page</a>."
        body += "<form><input type='submit' value='Mark Your Request as Completed'></form>"
      else
        # This block represents the welcome-buyer case
        recipient = email.buy_request.netid + "@princeton.edu"
        subject += "You now have a buy request in for #{showTitle}"

        body += "<p>You now have a buy request in for:</p>"
        timeString = show.time.in_time_zone("America/New_York").strftime('%B %d, %Y %l:%M %p')
        body += "<p>#{showTitle} at #{timeString}</p>"

        sellRequests = show.sell_requests
        if sellRequests.length == 0
          body += "<p>There are currnetly no sellers for this ticket, but we will let you know as soon as somebody puts up a sell request.</p>"
        else
          body += "<p>Here are the people interested in selling this ticket:</p>"
          buyRequests.each do |buyRequest|
            netid = buyRequest.netid
            body += "netid: #{netid}, email: #{netid}@princeton.edu <br />"
          end
          body += "<p>We have sent them emails, but as a buyer we recommend that you contact them to make sure this exchange happens!</p>"
        end
        body += "Once you have made an arrangment with someone, simply click the button below to stop recieving notifications. You can also change the status of your request on the <a href='tiger-tickets.herokuapp.com/my-tix'>my-tix page</a>."
        body += "<form><input type='submit' value='Mark Your Request as Completed'></form>"
      end
      # Shared part for both buying and selling.
      sendEmail([recipient], subject, body, email)
    when "new-seller", "new-buyer"
      show = email.show
      showTitle = show.title
      recipient = ""
      subject = ""
      body = ""

      timeString = show.time.in_time_zone("America/New_York").strftime('%B %d, %Y %l:%M %p')
      if email.email_type == "new-seller"
        recipient = email.buy_request.netid + "@princeton.edu"
        subject += "There is a new seller for #{showTitle}!"
        body += "<p>There is a new seller for #{showTitle}!:</p>"
        netid = email.sell_request.netid
        body += "netid: #{netid}, email: #{netid}@princeton.edu <br />"
        body += "<p>Here are the show details:</p>"
        body += "<p>#{showTitle} at #{timeString}</p>"
        body += "<p>If you would like to buy this ticket, please send them an email as soon as you can. Other buyers have been notofied as well.</p>"
        body += "<p>Once you have made an arrangment with someone, simply click the button below to stop recieving notifications. You can also change the status of your request on the <a href='tiger-tickets.herokuapp.com/my-tix'>my-tix page</a>.</p>"
        body += "<form><input type='submit' value='Mark Your Request as Completed'></form>"
      else
        recipient = email.sell_request.netid + "@princeton.edu"
        subject += "There is a new buyer for #{showTitle}!"
        body += "<p>There is a new buyer for #{showTitle}!:</p>"
        netid = email.buy_request.netid
        body += "netid: #{netid}, email: #{netid}@princeton.edu <br />"
        body += "<p>Here are the show details:</p>"
        body += "<p>#{showTitle} at #{timeString}</p>"
        body += "<p>We have notified this buyer that you are selling, and we encouraged them to contact you. That said, feel free to reach out to them as well.</p>"
        body += "<p>Once you have made an arrangment with someone, simply click the button below to stop recieving notifications. You can also change the status of your request on the <a href='tiger-tickets.herokuapp.com/my-tix'>my-tix page</a>.</p>"
        body += "<form><input type='submit' value='Mark Your Request as Completed'></form>"
      end
      # Shared part for both buying and selling.
      sendEmail([recipient], subject, body, email)
    end
  end

  def sendEmail(recipients, subject, body, emailHistory)
    # Get recipients
    to = []
    recipients.each do |recipient|
      to << {"email": recipient}
    end
    
    puts "**************EMAIL RECIPIENTS**************"
    puts to


    # Create content
    
    puts "**************EMAIL BODY********************"
    puts body
    
    data = {
      "personalizations": [
        {
          "to": to,
          "subject": subject
        }
      ],
      "from": {
        "email": "No-Reply-Tiger-Tickets@princeton.edu",
        "name": "Tiger Tickets!"
      },
      "content": [
        {
          "type": "text/html",
          "value": body
        }
      ]
    }
    
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    if response.status_code.to_i == 202
      emailHistory.update(status: "sent")
    else
      emailHistory.update(status: "failed")
    end
    puts response.body
    puts response.headers
  end


end
