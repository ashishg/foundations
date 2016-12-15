class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      #t.string :commenter
      t.text :body
      t.references :project, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :project_revision, index: true, foreign_key: true    # FIXME: index=true?

      t.timestamps null: false
    end
    #add_foreign_key :comments, :projects
  end
end
