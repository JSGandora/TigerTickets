class EmailHistory < ApplicationRecord
    belongs_to :sell_request
    belongs_to :buy_request
end
