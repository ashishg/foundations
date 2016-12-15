# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160307213750) do

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "project_revision_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "comments", ["project_id"], name: "index_comments_on_project_id"
  add_index "comments", ["project_revision_id"], name: "index_comments_on_project_revision_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "project_revisions", force: :cascade do |t|
    t.integer  "revision"
    t.string   "title"
    t.text     "description"
    t.integer  "cost"
    t.integer  "cost_min"
    t.integer  "cost_step"
    t.integer  "vote_count"
    t.string   "address"
    t.text     "url"
    t.boolean  "uses_slider", default: false
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "project_revisions", ["project_id"], name: "index_project_revisions_on_project_id"
  add_index "project_revisions", ["user_id"], name: "index_project_revisions_on_user_id"

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "cost"
    t.integer  "cost_min"
    t.integer  "cost_step"
    t.string   "address"
    t.text     "url"
    t.boolean  "uses_slider", default: false
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "projects", ["user_id"], name: "index_projects_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "votes", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
