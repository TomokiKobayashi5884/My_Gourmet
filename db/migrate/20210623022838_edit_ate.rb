class EditAte < ActiveRecord::Migration[5.2]
  def change
    change_column :posts, :ate, :string, null: false
  end
end
