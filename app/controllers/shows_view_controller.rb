class ShowsViewController < ApplicationController
  def getshows
  	shows = Show.all
    showsResponse = []
    for show in shows
      showsResponse << {:id => show['id'], :title => show['title'], :time => show['time'].to_i, :location => show['location'], :group => show['group']}
    end
    response = { :status => "ok", :shows => showsResponse}
    render json: response
  end
end
