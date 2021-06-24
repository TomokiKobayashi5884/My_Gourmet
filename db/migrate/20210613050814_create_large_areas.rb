class CreateLargeAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :large_areas do |t|
      t.string :name,    null:false

      t.timestamps
    end
  end
end
