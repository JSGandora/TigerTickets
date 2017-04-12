class AddImgToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :img, :string
  end
end
