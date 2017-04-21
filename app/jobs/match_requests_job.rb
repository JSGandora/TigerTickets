class MatchRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pendingEmails = EmailHistory.select("buy_requests.netid AS buy_request_netid, sell_requests.netid AS sell_request_netid, shows.*").where(status: "pending").joins(:buy_request).joins(:sell_request).joins("JOIN shows ON sell_requests.show_id = shows.id")
    n = 0
    pendingEmails.each do |email|
      buyer_email = email.buy_request_netid + "@princeton.edu"
      seller_email = email.sell_request_netid + "@princeton.edu"
      show = {:time => email.time, :title => email.title}
      puts "hi from above job call"
      MailMatchesJob.perform_later([[buyer_email,"Buying"], [seller_email, "Selling"]], show)
      n += 1
    end
  end
end
