class SellRequest < ApplicationRecord
    has_many :email_histories, :dependent => :delete_all
    has_many :buy_requests, through: :email_histories
end
