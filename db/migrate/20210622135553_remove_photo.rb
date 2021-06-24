class RemovePhoto < ActiveRecord::Migration[5.2]
  def change
    remove_column :restaurants, :photo, :string
  end
end
