class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :salt
      t.string :name
      #t.boolean :is_superadmin, default: false
      #t.boolean :confirmed, default: false
      #t.string :confirmation_id

      t.timestamps
    end

    add_index(:users, :username, unique: true)
  end
end
