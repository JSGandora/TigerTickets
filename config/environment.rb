# Load the Rails application.
require_relative 'application'

require 'casclient'
require 'casclient/frameworks/rails/filter'

  CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url  => "https://fed.princeton.edu/cas/",
    :login_url     => "https://fed.princeton.edu/cas/login",
    :logout_url    => "https://fed.princeton.edu/cas/logout",
    :validate_url  => "https://fed.princeton.edu/cas/serviceValidate",
  )

ActionMailer::Base.smtp_settings = {
  :user_name => ENV['SENDGRID_USERNAME'],
  :password => ENV['SENDGRID_PASSWORD'],
  :domain => 'heroku.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

# Initialize the Rails application.
Rails.application.initialize!

