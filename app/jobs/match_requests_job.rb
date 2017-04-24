class MatchRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pendingEmails = EmailHistory.where(status: "pending")
    n = 0
    pendingEmails.each do |email|
      MailMatchesJob.set(wait: n.seconds).perform_later(email)
      email.update(status: "processed")
      n += 5
    end
  end
end
