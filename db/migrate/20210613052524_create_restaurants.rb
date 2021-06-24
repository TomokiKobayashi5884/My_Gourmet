class CreateRestaurants < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :open_time
      t.string :close_day
      t.integer :hotpepper_id
      t.references :large_area, foreign_key: true
      t.references :middle_area, foreign_key: true

      t.timestamps
    end
  end
end
