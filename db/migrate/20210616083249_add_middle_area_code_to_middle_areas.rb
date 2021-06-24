class AddMiddleAreaCodeToMiddleAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :middle_areas, :middle_area_code, :string
  end
end
