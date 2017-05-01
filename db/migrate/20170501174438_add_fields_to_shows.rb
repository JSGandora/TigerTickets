class AddFieldsToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :soldout, :boolean, default: false
    add_column :shows, :buy_link, :string, default: ""
  end
end
