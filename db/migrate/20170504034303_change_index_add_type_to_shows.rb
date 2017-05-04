class ChangeIndexAddTypeToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :website, :string
    
    add_column :shows, :website_id, :string
    add_index :shows, :website_id, unique: true
  end
end
