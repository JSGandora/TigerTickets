class WelcomeController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_action CASClient::Frameworks::Rails::Filter, :except => :index
  before_action CASClient::Frameworks::Rails::GatewayFilter, :only => :index
  def index
  end
  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  def mytix
  end

  def calendar
  end

  def login
    redirect_to "/"
  end
end
