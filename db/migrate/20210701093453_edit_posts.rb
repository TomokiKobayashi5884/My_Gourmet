class EditPosts < ActiveRecord::Migration[5.2]
  def change
    change_column :posts, :ate, :boolean, null: false, default: true
    # remove_column :posts, :ate, :string
    # add_column :posts, :ate, :boolean, null: false, default: true 
  end
end
