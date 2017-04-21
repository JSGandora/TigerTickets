class MatchRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pendingEmails = EmailHistory.where(status: "pending")
    n = 0
    pendingEmails.each do |email|
      buyer_email = email.buy_request.netid + "@princeton.edu"
      seller_email = email.sell_request.netid + "@princeton.edu"
      show = email.sell_request.show
      puts "hi from above job call"
      MailMatchesJob.set(wait: n.seconds).perform_later([[buyer_email,"Buying"], [seller_email, "Selling"]], show, email)
      email.update(status: "processed")
      n += 5
    end
  end
end
