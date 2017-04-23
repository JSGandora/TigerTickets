class AddSecureTokenToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :buy_requests, :email_token, :string
    add_index :buy_requests, :email_token, unique: true
    
    add_column :sell_requests, :email_token, :string
    add_index :sell_requests, :email_token, unique: true
  end
end
