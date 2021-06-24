class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title,  null: false
      t.text :content
      t.boolean :ate, default: false, null: false
      t.string :image, null: false
      t.references :user, foreign_key: true
      t.references :genre, foreign_key: true
      t.references :restaurant, foreign_key: true
      

      t.timestamps
    end
  end
end
