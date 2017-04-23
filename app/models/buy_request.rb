class BuyRequest < ApplicationRecord
    has_secure_token :email_token
    has_many :email_histories, :dependent => :delete_all
    has_many :sell_requests, through: :email_histories
    belongs_to :show
end
