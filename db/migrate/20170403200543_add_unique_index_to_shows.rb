class AddUniqueIndexToShows < ActiveRecord::Migration[5.0]
  def change
    add_index :shows, [:title, :time, :location, :group], unique: true
  end
end
