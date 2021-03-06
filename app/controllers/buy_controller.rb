class BuyController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_action CASClient::Frameworks::Rails::Filter, :except => :complete_buy_token
  
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
    buyRequestCount = BuyRequest.where(netid: netid).where(show_id: show_id).where(status: "waiting-for-match").count
    # This is the ticket request cap. It should be 0 in production but it is at 1 (which means we allow 2 connurrent requests) for dev.
    if buyRequestCount > 0
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has a buy requests for this show'}
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
  def complete_buy_token
    status = ""
    reason = ""
    token = params[:email_token]
    if token
      buyRequests = BuyRequest.where(email_token: token).where(:status => ["waiting-for-match", "completed"])
      if buyRequests.length > 0
        buyRequests.update_all(status: "completed", updated_at: DateTime.now)
        status = "ok"
      else
        status = "Bad request"
        reason = "Tampered token. We have alerted the authorities."
        response = { :status => status, :reason => reason}
        render json: response
        return
      end
    else
      status = "Bad request"
      reason = "No authentication/token"
      response = { :status => status, :reason => reason}
      render json: response
      return
    end
    # Old redirect version. We now give them an info page instead.
    #redirect_to "/my-tix"
    #return
  end
  
  # Marks buy request as completed
  def complete_buy
    status = ""
    netid = ""
    buy_request_id = ""
    reason = ""
    
    # Checks if user is logged in
    if user_is_logged_in?
      netid = session[:cas_user]
      buy_request_id = params[:buy_request_id]
      # Checks if there was a buy_request_id
      if buy_request_id
        buyRequests = BuyRequest.where(netid: netid).where(id: buy_request_id).where(:status => ["waiting-for-match"])
        # Checks if the buy request is valid
        if buyRequests.length > 0
          buyRequests.update_all(status: "completed", updated_at: DateTime.now)
          status = "ok"
        else
          status = "Bad request"
          reason = "No buy requests found"
        end
      else
        status = "Bad request"
        reason = "Missing buy_request_id"
      end
    else
      status = "Bad request."
      reason = "Not logged in."
    end
    
    # Return response in JSON
    response = { :status => status, :netid => netid, :buy_request_id => buy_request_id, :reason => reason}
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
      buyRequests.update_all(status: "deleted", updated_at: DateTime.now)
      response = {:status => "ok", :netid => netid, :buy_request_id => buy_request_id}
      render json: response
    end
  end

end
