class AccountController < ApplicationController
  before_action CASClient::Frameworks::Rails::Filter
  def mytix
    netid = session[:cas_user]
    buyRequests = BuyRequest.select("show_id, title, shows.time AS time, location, `group`, img, buy_requests.id AS buy_request_id, status").where(netid: netid).where(:status => ["waiting-for-match", "pending", "completed"]).joins("INNER JOIN shows ON shows.id = buy_requests.show_id")
    sellRequests = SellRequest.select("show_id, title, shows.time AS time, location, `group`, img, sell_requests.id AS sell_request_id, status").where(netid: netid).where(:status => ["waiting-for-match", "pending", "completed"]).joins("INNER JOIN shows ON shows.id = sell_requests.show_id")






    buyRequestResponse = []
    for buyRequest in buyRequests
      show = {:id => buyRequest['show_id'], :name => buyRequest['title'], :time => (DateTime.parse(buyRequest['time'])).to_i, 
        :location => buyRequest['location'], :group => buyRequest['group'], 
        :image => buyRequest['img'],
        :price => 0}

      buyRequestResponse << {
        :id => buyRequest['buy_request_id'],
        :netid => netid,
        :status => buyRequest['status'],
        :show => show
      }
    end

    sellRequestResponse = []
    for sellRequest in sellRequests
      show = {:id => sellRequest['show_id'], :name => sellRequest['title'], :time => (DateTime.parse(sellRequest['time'])).to_i, 
        :location => sellRequest['location'], :group => sellRequest['group'], 
        :image => sellRequest['img'],
        :price => 0}

      sellRequestResponse << {
        :id => sellRequest['sell_request_id'],
        :netid => netid,
        :status => sellRequest['status'],
        :show => show
      }
    end


    response = { :status => "ok", :netid => netid, :buyrequests => buyRequestResponse, :sellrequests => sellRequestResponse}
    render json: response
  end
end
