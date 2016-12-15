class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.integer :cost
      t.integer :cost_min
      t.integer :cost_step
      #t.integer :vote_count
      t.string :address
      t.text :url
      t.boolean :uses_slider, default: false
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
