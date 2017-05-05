require 'sendgrid-ruby'
include SendGrid

class FeedbackController < ApplicationController
  skip_before_action :verify_authenticity_token
  def feedback_email
    feedbackName = params[:name]
    email = params[:email]
    message = params[:comment]
    @emailStatus = sendEmail(["birgelee@princeton.edu"], "#{feedbackName} gave feedback to Tiger Tickets", "#{feedbackName} gave feedback to Tiger Tickets <br /> Their email is: #{email}. Their comment is: <br /> #{message}")
  end

  def sendEmail(recipients, subject, body)
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
    puts response.body
    puts response.headers
    if response.status_code.to_i == 202
      return true
    else
      return false
    end
  end
end
