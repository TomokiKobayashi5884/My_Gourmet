class EditLargeAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :large_areas, :large_area_code, :string
    remove_column :middle_areas, :large_area_name
  end
end
