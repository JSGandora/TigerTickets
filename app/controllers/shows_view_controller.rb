class ShowsViewController < ApplicationController
  def getshows
  	@shows = Show.all
    respond_to do |format|
      #format.html
      response = { :status => "ok", :shows => @shows}
      format.json { render json: response}
    end
  end
end
