class MatchRequestsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # This method will go through and match buy requests with sell requests, update the DB with the matches, and send out an email to the people who are matched.
  end
end
