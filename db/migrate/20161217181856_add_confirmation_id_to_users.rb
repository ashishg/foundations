class AddConfirmationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_id, :string
  end
end
