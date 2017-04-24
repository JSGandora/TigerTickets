class AddTypeToEmails < ActiveRecord::Migration[5.0]
  def change
    add_column :email_histories, :email_type, :string
    add_reference :email_histories, :show, index: true
    add_foreign_key :email_histories, :shows
  end
end
