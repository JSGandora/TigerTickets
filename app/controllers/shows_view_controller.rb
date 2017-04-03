class ShowsViewController < ApplicationController
  def getshows
  	@shows = Show.all
    response = { :status => "ok", :shows => @shows}
    render json: response
  end
end
