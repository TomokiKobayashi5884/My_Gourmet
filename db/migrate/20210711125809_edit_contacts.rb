class EditContacts < ActiveRecord::Migration[5.2]
  def change
    rename_column :contacts, :title, :subject
    rename_column :contacts, :content, :message
  end
end
