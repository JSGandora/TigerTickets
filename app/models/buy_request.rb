class BuyRequest < ApplicationRecord
    has_many :email_histories, :dependent => :delete_all
    has_many :sell_requests, through: :email_histories
end
