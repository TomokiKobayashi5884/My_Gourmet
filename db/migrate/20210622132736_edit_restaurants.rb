class EditRestaurants < ActiveRecord::Migration[5.2]
  def change
    remove_column :restaurants, :phone, :string 
    add_column :restaurants, :photo, :string
    add_column :restaurants, :urls, :string
  end
end
