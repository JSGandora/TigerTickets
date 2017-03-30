class CreateSellRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :sell_requests do |t|
      t.string  :netid
      t.string  :status
      t.integer :show_id
      t.timestamps
    end
    add_foreign_key :sell_requests, :shows
  end
end
