class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.belongs_to :project
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
