class RenameUrls < ActiveRecord::Migration[5.2]
  def change
    rename_column :restaurants, :urls, :url
  end
end
