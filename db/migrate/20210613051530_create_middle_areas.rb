class CreateMiddleAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :middle_areas do |t|
      t.string :name,      null: false
      t.references :large_area, foreign_key: true

      t.timestamps
    end
  end
end
