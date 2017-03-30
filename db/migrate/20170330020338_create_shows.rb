class CreateShows < ActiveRecord::Migration[5.0]
  def change
    create_table :shows do |t|
      t.string :title
      t.datetime :time
      t.string :location
      t.string :group

      t.timestamps
    end
  end
end
