class MatchRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # This method will go through and match buy requests with sell requests, update the DB with the matches, and send out an email to the people who are matched.
    # This code will eventually only select upcomming shows.
    buyRequests = BuyRequest.where(status: "waiting-for-match").order(:created_at)
    buyRequests.each do |buyRequest|
      sellRequests = SellRequest.where(status: "waiting-for-match").where(show_id: buyRequest.show_id).order(:created_at)
      if not (sellRequests.length == 0)
        puts "*****MATCHING HAPPNEING*********"
        sellRequest = sellRequests.first
        puts "*******NEXT*******"
        buyRequest.update(sell_request_id: sellRequest.id)
        puts "*****MATCHING JOIN TABLE ADDED*********"
        sellRequest.update(status: "pending")
        buyRequest.update(status: "pending")
        puts "*****STATUS CHANGED*********"
        
        puts "***********SENDING EMAIL************"
        show = Show.find(buyRequest.show_id)
        buyer_email = buyRequest.netid + "@princeton.edu"
        seller_email = sellRequest.netid + "@princeton.edu"
        MailMatchesJob.perform_later([[buyer_email,"Buying"], [seller_email, "Selling"]], show)
      end
    end
  end
end
