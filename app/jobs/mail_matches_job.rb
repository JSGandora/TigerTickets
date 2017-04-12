require 'sendgrid-ruby'
include SendGrid
class MailMatchesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "rdu@princeton.edu"
            }
          ],
          "subject": "Hello World from the SendGrid Ruby Library!"
        }
      ],
      "from": {
        "email": "test@example.com"
      },
      "content": [
        {
          "type": "text/plain",
          "value": "Hello, Email!"
        }
      ]
    }')
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end
