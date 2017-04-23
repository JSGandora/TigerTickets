class SellRequest < ApplicationRecord
    has_secure_token :email_token
    has_many :email_histories, :dependent => :delete_all
    has_many :buy_requests, through: :email_histories
    belongs_to :show
end
