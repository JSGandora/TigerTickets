class SellController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_action CASClient::Frameworks::Rails::Filter, :except => :complete_sell_token
  
  def sellrequest
    # This is the action exposed with POST /sell
    show_id = params[:show_id]
    netid = session[:cas_user]
    if not show_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing show_id'}
      render json: response
      return
    end
    buyRequestCount = BuyRequest.where(netid: netid).where(show_id: show_id).where(status: "waiting-for-match").count
    if buyRequestCount > 0
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has ' + buyRequestCount.to_s + ' buy requests waiting for a match for this show'}
      render json: response
      return
    end
    sellRequestCount = SellRequest.where(netid: netid).where(show_id: show_id).where(status: "waiting-for-match").count
    # This is the ticket request cap. It should be 0 in production but it is at in development 1 (which means we allow 2 connurrent requests) for dev.
    if sellRequestCount > 0
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has a sell requests for this show'}
      render json: response
      return
    end
    sellRequest = SellRequest.create(netid: netid, status: 'waiting-for-match', show_id: show_id)

    buyRequests = BuyRequest.where(show_id: show_id).where(status: 'waiting-for-match')
    buyRequests.each do |buyRequest|
      EmailHistory.create(status: "pending", buy_request: buyRequest, sell_request: sellRequest, show: sellRequest.show, email_type: "new-seller")
    end
    EmailHistory.create(status: "pending", sell_request: sellRequest, show: sellRequest.show, email_type: "welcome-seller")

    MatchRequestsJob.perform_later()

    response = { :status => "ok", :netid => netid, :show_id => show_id, :sell_request_id => sellRequest.id}
    render json: response
  end
  
  # Marks sell request as completed
  def complete_sell_token
    status = ""
    reason = ""
    token = params[:email_token]
    if token
      sellRequests = SellRequest.where(email_token: token).where(:status => ["waiting-for-match", "completed"])
      if sellRequests.length > 0
        sellRequests.update_all(status: "completed", updated_at: DateTime.now)
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
    # Old redirect version. We now load a view instead.
    #redirect_to "/my-tix"
    #return
  end
  
  # Marks sell request as completed
  def complete_sell
    status = ""
    netid = ""
    sell_request_id = ""
    reason = ""
    
    # Checks if user is logged in
    if user_is_logged_in?
      netid = session[:cas_user]
      sell_request_id = params[:sell_request_id]
      # Checks if there was a sell_request_id
      if sell_request_id
        sellRequests = SellRequest.where(netid: netid).where(id: sell_request_id).where(:status => ["waiting-for-match"])
        # Checks if the sell request is valid
        if sellRequests.length > 0
          sellRequests.update_all(status: "completed", updated_at: DateTime.now)
          status = "ok"
        else
          status = "Bad request"
          reason = "No sell requests found"
        end
      else
        status = "Bad request"
        reason = "Missing sell_request_id"
      end
    else
      status = "Bad request."
      reason = "Not logged in."
    end
    
    # Return response in JSON
    response = { :status => status, :netid => netid, :sell_request_id => sell_request_id, :reason => reason}
    render json: response
    return
  end

  def deletesell
    sell_request_id = params[:sell_request_id]
    netid = session[:cas_user]
    if not sell_request_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing sell_request_id'}
      render json: response
      return
    end
    # This should stop someone from deleting someone else's sell request.
    sellRequests = SellRequest.where(netid: netid).where(id: sell_request_id).where(:status => ["waiting-for-match"])
    
    # Need to add update of mail history.
    MailMatchesJob.perform_later()
    if sellRequests.length == 0
      response = {:status => "bad request", :netid => netid, :reason => 'no sell requests found'}
      render json: response
    else
      sellRequests.update_all(status: "deleted", updated_at: DateTime.now)
      response = {:status => "ok", :netid => netid, :sell_request_id => sell_request_id}
      render json: response
    end
  end
end
