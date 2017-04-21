class AddBelogsToToRequests < ActiveRecord::Migration[5.0]
  def change
    change_table :buy_requests do |t|
      t.remove :show_id
      t.belongs_to :show, index: true
    end

    change_table :sell_requests do |t|
      t.remove :show_id
      t.belongs_to :show, index: true
    end
  end
end
