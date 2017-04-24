class BuyController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_action CASClient::Frameworks::Rails::Filter
  def buyrequest
    # This is the action exposed with POST /buy
    show_id = params[:show_id]
    netid = session[:cas_user]
    if not show_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing show_id'}
      render json: response
      return
    end
    sellRequestCount = SellRequest.where(netid: netid).where(show_id: show_id).where(:status => ["waiting-for-match", "pending"]).count
    if sellRequestCount > 0
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has ' + sellRequestCount.to_s + ' sell requests waiting for a match for this show'}
      render json: response
      return
    end
    buyRequestCount = BuyRequest.where(netid: netid).where(show_id: show_id).count
    if buyRequestCount > 1
      response = { :status => "bad request", :netid => netid, :reason => 'this user already has 2 buy requests for this show'}
      render json: response
      return
    end
    buyRequest = BuyRequest.create(netid: netid, status: 'waiting-for-match', show_id: show_id)

    sellRequests = SellRequest.where(show_id: show_id).where(status: 'waiting-for-match')
    sellRequests.each do |sellRequest|
      EmailHistory.create(status: "pending", buy_request: buyRequest, sell_request: sellRequest)
    end

    MatchRequestsJob.perform_later()
    
    response = { :status => "ok", :netid => netid, :show_id => show_id, :buy_request_id => buyRequest.id}
    render json: response
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
    buyRequests = BuyRequest.where(netid: netid).where(id: buy_request_id).where(:status => ["waiting-for-match", "pending"])
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
