class CreateEmailHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :email_histories do |t|
      t.belongs_to :sell_request, index: true
      t.belongs_to :buy_request, index: true
      t.string :status
      
      t.timestamps
    end
    
    change_table :buy_requests do |t|
      t.remove :sell_request_id
    end
  end
end
