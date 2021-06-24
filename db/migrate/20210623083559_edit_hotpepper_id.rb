class EditHotpepperId < ActiveRecord::Migration[5.2]
  def change
    remove_column :restaurants, :hotpepper_id, :integer
    add_column :restaurants, :hotpepper_id, :string
  end
end
