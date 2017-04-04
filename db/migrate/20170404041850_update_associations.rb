class UpdateAssociations < ActiveRecord::Migration[5.0]
  def change
    drop_table :buy_requests_sell_requests
    add_column :buy_requests, :sell_request_id, :integer
  end
end
