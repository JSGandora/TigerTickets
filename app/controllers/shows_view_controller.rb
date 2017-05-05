class ShowsViewController < ApplicationController
  def getshows
  	shows = Show.select('SUM(CASE WHEN sell_requests.status = \'waiting-for-match\' THEN 1 ELSE 0 END) AS sell_request_count, shows.*')
      .where(["time > ?", Time.current])
      .joins('LEFT JOIN sell_requests ON shows.id = sell_requests.show_id')
      .group('shows.id')
      .order(:time)


      shows2 = Show.select('SUM(CASE WHEN buy_requests.status = \'waiting-for-match\' THEN 1 ELSE 0 END) AS buy_request_count')
      .where(["time > ?", Time.current])
      .joins('LEFT JOIN buy_requests ON shows.id = buy_requests.show_id')
      .group('shows.id')
      .order(:time)
      
    showsResponse = []
    for i in 0..(shows.length - 1)
      show = shows[i]
      showsResponse << {:id => show['id'], :name => show['title'], :time => show['time'].to_i, 
        :location => show['location'], :group => show['group'], 
        :image => show['img'],
        :buyreq => shows2[i]['buy_request_count'],
        :sellreq => show['sell_request_count'],
        :price => 0,
        :soldout => show['soldout'],
        :buy_link => show['buy_link'],
        :office_from => show['website']
      }
    end
    response = { :status => "ok", :shows => showsResponse, :netid => netid = session[:cas_user] }
    render json: response
  end
end
