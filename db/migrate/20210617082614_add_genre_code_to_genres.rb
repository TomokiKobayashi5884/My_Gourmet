class AddGenreCodeToGenres < ActiveRecord::Migration[5.2]
  def change
    add_column :genres, :genre_code, :string
  end
end
