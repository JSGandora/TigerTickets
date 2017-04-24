class BuyController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_action CASClient::Frameworks::Rails::Filter, :except => :complete_buy
  
  def buyrequest
    # This is the action exposed with POST /buy
    show_id = params[:show_id]
    netid = session[:cas_user]
    if not show_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing show_id'}
      render json: response
      return
    end
    sellRequestCount = SellRequest.where(netid: netid).where(show_id: show_id).where(status: "waiting-for-match").count
    if sellRequestCount > 0
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has ' + sellRequestCount.to_s + ' sell requests waiting for a match for this show'}
      render json: response
      return
    end
    buyRequestCount = BuyRequest.where(netid: netid).where(show_id: show_id).where(:status => ["waiting-for-match", "completed"]).count
    if buyRequestCount > 1
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has 2 buy requests for this show'}
      render json: response
      return
    end
    buyRequest = BuyRequest.create(netid: netid, status: 'waiting-for-match', show_id: show_id)

    sellRequests = SellRequest.where(show_id: show_id).where(status: 'waiting-for-match')
    sellRequests.each do |sellRequest|
      EmailHistory.create(status: "pending", buy_request: buyRequest, sell_request: sellRequest, show: buyRequest.show, email_type: "new-buyer")
    end
    
    EmailHistory.create(status: "pending", buy_request: buyRequest, show: buyRequest.show, email_type: "welcome-buyer")

    MatchRequestsJob.perform_later()
    
    response = { :status => "ok", :netid => netid, :show_id => show_id, :buy_request_id => buyRequest.id}
    render json: response
  end
  
  
  # Marks buy request as completed
  def complete_buy
    token = params[:email_token]
    status = ""
    netid = ""
    buy_request_id = ""
    reason = ""
    type = ""
    
    # If token exists, checks if it's a valid token
    if token
      buyRequests = BuyRequest.where(email_token: token).where(:status => ["waiting-for-match"])
      if buyRequests.length > 0
        BuyRequest.update_all(status: "completed")
        status = "ok"
        type = "token"
      else
        status = "Bad request"
        reason = "Invalid token"
      end
      
    # Checks if user is logged in
    elsif user_is_logged_in?
      netid = session[:cas_user]
      buy_request_id = params[:buy_request_id]
      # Checks if there was a buy_request_id
      if buy_request_id
        buyRequests = BuyRequest.where(netid: netid).where(id: buy_request_id).where(:status => ["waiting-for-match"])
        # Checks if the buy request is valid
        if buyRequests.length > 0
          BuyRequest.update_all(status: "completed")
          status = "ok"
          type = "netid"
        else
          status = "Bad request"
          reason = "No buy requests found"
        end
      else
        status = "Bad request"
        reason = "Missing buy_request_id"
      end
    else
      status = "Bad request"
      reason = "No authentication/token"
    end
    
    # Return response in JSON
    response = { :status => status, :netid => netid, :buy_request_id => buy_request_id, :reason => reason, :type => type}
    render json: response
    return
  end

  def deletebuy
    # This is the action exposed with POST /cancelbuy
    buy_request_id = params[:buy_request_id]
    netid = session[:cas_user]
    # Assert buy request id is in params
    if not buy_request_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing buy_request_id'}
      render json: response
      return
    end
    # This should stop someone from deleting someone else's buy request.
    buyRequests = BuyRequest.where(netid: netid).where(id: buy_request_id).where(:status => ["waiting-for-match"])
    MatchRequestsJob.perform_later
    if buyRequests.length == 0
      response = {:status => "bad request", :netid => netid, :reason => 'no buy requests found'}
      render json: response
    else
      buyRequests.update_all(status: "deleted")
      response = {:status => "ok", :netid => netid, :buy_request_id => buy_request_id}
      render json: response
    end
  end

end
