class AccountController < ApplicationController
  before_action CASClient::Frameworks::Rails::Filter
  def mytix
    netid = session[:cas_user]
    buyRequests = BuyRequest.select("show_id, title, time, location, \"group\", img, buy_requests.id AS buy_request_id, status").where(netid: netid).where(:status => ["waiting-for-match", "pending", "completed"]).where(["time > ?", Time.current]).joins("INNER JOIN shows ON shows.id = buy_requests.show_id")
    sellRequests = SellRequest.select("show_id, title, time, location, \"group\", img, sell_requests.id AS sell_request_id, status").where(netid: netid).where(:status => ["waiting-for-match", "pending", "completed"]).where(["time > ?", Time.current]).joins("INNER JOIN shows ON shows.id = sell_requests.show_id")



    buyRequestResponse = []
    for buyRequest in buyRequests
      #this code is needed because SQLite returns a string while PG returns a timestamp.
      buyRequestTime = 0
      if buyRequest['time'].is_a? String
        buyRequestTime = (DateTime.parse(buyRequest['time'])).to_i
      else
        buyRequestTime = buyRequest['time'].to_i
      end


      show = {:id => buyRequest['show_id'], :name => buyRequest['title'], :time => buyRequestTime, 
        :location => buyRequest['location'], :group => buyRequest['group'], 
        :image => buyRequest['img'],
        :price => 0}

      showSellRequests = SellRequest.where(show_id: buyRequest['show_id']).where(status: "waiting-for-match")
      sellerList = []
      for sellRequest in showSellRequests
        sellerList << sellRequest.netid
      end

      buyRequestResponse << {
        :id => buyRequest['buy_request_id'],
        :netid => netid,
        :status => buyRequest['status'],
        :seller_list => sellerList,
        :show => show
      }
    end

    sellRequestResponse = []
    for sellRequest in sellRequests
      
      sellRequestTime = 0
      if sellRequest['time'].is_a? String
        sellRequestTime = (DateTime.parse(sellRequest['time'])).to_i
      else
        sellRequestTime = sellRequest['time'].to_i
      end

      show = {:id => sellRequest['show_id'], :name => sellRequest['title'], :time => sellRequestTime, 
        :location => sellRequest['location'], :group => sellRequest['group'], 
        :image => sellRequest['img'],
        :price => 0}

      showBuyRequests = BuyRequest.where(show_id: sellRequest['show_id']).where(status: "waiting-for-match")
      buyerList = []
      for buyRequest in showBuyRequests
        buyerList << buyRequest.netid
      end

      sellRequestResponse << {
        :id => sellRequest['sell_request_id'],
        :netid => netid,
        :status => sellRequest['status'],
        :buyer_list => buyerList,
        :show => show
      }
    end


    response = { :status => "ok", :netid => netid, :buyrequests => buyRequestResponse, :sellrequests => sellRequestResponse}
    render json: response
  end
end
