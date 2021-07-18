class AddAgreementPrivacy < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :agreement_privacy, :boolean, default: false, null: false
  end
end
