class ShowsViewController < ApplicationController
  def getshows
  	shows = Show.select('SUM(CASE WHEN sell_requests.status = \'waiting-for-match\' THEN 1 ELSE 0 END) AS sell_request_count, SUM(CASE WHEN buy_requests.status = \'waiting-for-match\' THEN 1 ELSE 0 END) as buy_request_count, shows.*')
      .where(["time > ?", Time.current])
      .joins('LEFT JOIN sell_requests ON shows.id = sell_requests.show_id')
      .joins('LEFT JOIN buy_requests ON shows.id = buy_requests.show_id')
      .group('shows.id')
      .order(:time)
      #.where('buy_requests.status IS NULL OR buy_requests.status = ?', 'waiting-for-match')
      #.where('sell_requests.status IS NULL OR sell_requests.status = ?', 'waiting-for-match')
      
    showsResponse = []
    for show in shows
      showsResponse << {:id => show['id'], :name => show['title'], :time => show['time'].to_i, 
        :location => show['location'], :group => show['group'], 
        :image => show['img'],
        :buyreq => show['buy_request_count'],
        :sellreq => show['sell_request_count'],
        :price => 0}
    end
    response = { :status => "ok", :shows => showsResponse, :netid => netid = session[:cas_user] }
    render json: response
  end
end
