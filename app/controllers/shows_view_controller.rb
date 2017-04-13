class ShowsViewController < ApplicationController
  before_action CASClient::Frameworks::Rails::GatewayFilter
  def getshows
  	shows = Show.select('count(sell_requests.show_id) as sell_request_count, count(buy_requests.show_id) as buy_request_count, shows.*')
      .where(["time > ?", Time.current])
      .joins('LEFT JOIN sell_requests ON shows.id = sell_requests.show_id')
      .joins('LEFT JOIN buy_requests ON shows.id = buy_requests.show_id')
      .group('shows.id')
      .where('buy_requests.status IS NULL OR buy_requests.status = ?', 'waiting-for-match')
      .where('sell_requests.status IS NULL OR sell_requests.status = ?', 'waiting-for-match')
      .order(:time)
    showsResponse = []
    for show in shows
      showsResponse << {:id => show['id'], :name => show['title'], :time => show['time'].to_i, 
        :location => show['location'], :group => show['group'], 
        :image => show['img'],
        :buyreq => show['buy_request_count'],
        :sellreq => show['sell_request_count'],
        :price => 0}
    end
    response = { :status => "ok", :shows => showsResponse, :netid => netid = session[:cas_user]}
    render json: response
  end
end
