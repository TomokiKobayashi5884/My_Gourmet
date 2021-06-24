class AddColumnToMiddleAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :middle_areas, :large_area_name, :string
  end
end
