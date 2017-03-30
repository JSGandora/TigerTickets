class CreateJoinTableBuyRequestSellRequest < ActiveRecord::Migration[5.0]
  def change
    create_join_table :buy_requests, :sell_requests do |t|
      t.index :buy_request_id
      t.index :sell_request_id
    end
  end
end
