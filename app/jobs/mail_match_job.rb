require 'sendgrid-ruby'
include SendGrid

class MailMatchJob < ApplicationJob
  queue_as :default

  def perform(*recipients)
    mail = Mail.new
    mail.from = Email.new(email: 'Tiger-Tickets@princeton.edu', name: 'Tiger Tickets!')
    mail.subject = "You've been matched!"
    personalization = Personalization.new
    
    recipients.each do |recipient|
      personalization.to = Email.new(email: recipient)
    end
    
    mail.personalizations = personalization
    mail.contents = Content.new(type: 'text/plain', value: "You've been matched! Go find them!")
    mail.contents = Content.new(type: 'text/html', value: "<html><body>You've been matched! Go find them!</body></html>")
    puts mail.to_json

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
