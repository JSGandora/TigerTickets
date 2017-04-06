class SellController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_filter CASClient::Frameworks::Rails::Filter
  def sellrequest
    show_id = params[:show_id]
    netid = session[:cas_user]
    if not show_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing show_id'}
      render json: response
      return
    end
    sellRequest = SellRequest.create(netid: netid, status: 'waiting-for-match', show_id: show_id)
    MatchRequestsJob.perform_later
    response = { :status => "ok", :netid => netid, :show_id => show_id, :sell_request_id => sellRequest.id}
    render json: response
  end

  def cancelsell
    sell_request_id = params[:sell_request_id]
    netid = session[:cas_user]
    if not sell_request_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing sell_request_id'}
      render json: response
      return
    end
    # This should stop someone from deleting someone else's sell request.
    deletedNumber = SellRequest.where(netid: netid).where(id: sell_request_id).where(:status => ["waiting-for-match", "pending"]).destroy_all.length
    MatchRequestsJob.perform_later
    if deletedNumber == 0
      response = {:status => "bad request", :netid => netid, :reason => 'no sell requests found'}
      render json: response
    else
      response = {:status => "ok", :netid => netid, :sell_request_id => sell_request_id}
      render json: response
    end
  end
end