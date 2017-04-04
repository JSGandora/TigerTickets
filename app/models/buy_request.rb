class BuyRequest < ApplicationRecord
  has_one :sell_request
end
