class EmailHistory < ApplicationRecord
    belongs_to :sell_request, optional: true
    belongs_to :buy_request, optional: true
    belongs_to :show
end
