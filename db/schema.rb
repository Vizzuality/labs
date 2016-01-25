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

ActiveRecord::Schema.define(version: 20160125170829) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "fuzzystrmatch"

  create_table "comments", force: :cascade do |t|
    t.text     "content",                      null: false
    t.integer  "commentable_id",               null: false
    t.string   "commentable_type", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                      null: false
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "dependencies", force: :cascade do |t|
    t.integer  "master_project_id", null: false
    t.integer  "sub_project_id",    null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "installations", force: :cascade do |t|
    t.integer  "server_id",                                       null: false
    t.string   "role",                limit: 255,                 null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_instance_id",                             null: false
    t.datetime "deleted_at"
    t.boolean  "closing",                         default: false
  end

  add_index "installations", ["deleted_at"], name: "index_installations_on_deleted_at", using: :btree
  add_index "installations", ["project_instance_id"], name: "index_installations_on_project_instance_id", using: :btree
  add_index "installations", ["server_id"], name: "index_installations_on_server_id", using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_instances", force: :cascade do |t|
    t.integer  "project_id",                                            null: false
    t.string   "name",               limit: 255,                        null: false
    t.string   "url",                limit: 255,                        null: false
    t.text     "backup_information"
    t.string   "stage",              limit: 255, default: "Production", null: false
    t.string   "branch",             limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "closing",                        default: false
  end

  add_index "project_instances", ["deleted_at"], name: "index_project_instances_on_deleted_at", using: :btree
  add_index "project_instances", ["project_id"], name: "index_project_instances_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",                 limit: 255,                 null: false
    t.text     "description",                                       null: false
    t.string   "url",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                         default: false
    t.string   "screenshot",            limit: 255
    t.string   "github_identifier",     limit: 255
    t.text     "dependencies"
    t.string   "state",                 limit: 255,                 null: false
    t.string   "current_lead",          limit: 255
    t.text     "hacks"
    t.text     "external_clients",                  default: [],                 array: true
    t.text     "project_leads",                     default: [],                 array: true
    t.text     "developers",                        default: [],                 array: true
    t.text     "pdrive_folders",                    default: [],                 array: true
    t.text     "dropbox_folders",                   default: [],                 array: true
    t.text     "pivotal_tracker_ids",               default: [],                 array: true
    t.text     "trello_ids",                        default: [],                 array: true
    t.date     "expected_release_date"
    t.string   "rails_version",         limit: 255
    t.string   "ruby_version",          limit: 255
    t.string   "postgresql_version",    limit: 255
    t.text     "other_technologies",                default: [],                 array: true
    t.text     "internal_clients",                  default: [],                 array: true
    t.text     "internal_description"
    t.text     "background_jobs"
    t.text     "cron_jobs"
    t.text     "user_access"
    t.float    "budget"
    t.float    "money_spent"
    t.integer  "design_days"
    t.integer  "backend_days"
    t.integer  "frontend_days"
    t.integer  "mgmt_days"
    t.integer  "data_days"
    t.integer  "research_days"
  end

  create_table "review_answers", force: :cascade do |t|
    t.integer  "review_id",                          null: false
    t.integer  "review_question_id",                 null: false
    t.boolean  "done",               default: false, null: false
    t.boolean  "skipped",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_questions", force: :cascade do |t|
    t.integer  "review_section_id",                 null: false
    t.text     "code",                              null: false
    t.text     "title",                             null: false
    t.text     "description"
    t.integer  "sort_order",        default: 0,     null: false
    t.boolean  "skippable",         default: false
    t.text     "auto_check"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_sections", force: :cascade do |t|
    t.text     "code",                   null: false
    t.text     "title",                  null: false
    t.integer  "sort_order", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "project_id",  null: false
    t.integer  "reviewer_id", null: false
    t.decimal  "result",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", force: :cascade do |t|
    t.string   "name",         limit: 255, null: false
    t.string   "domain",       limit: 255, null: false
    t.string   "username",     limit: 255
    t.string   "admin_url",    limit: 255
    t.string   "os",           limit: 255, null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "ssh_key_name"
    t.datetime "deleted_at"
  end

  add_index "servers", ["deleted_at"], name: "index_servers_on_deleted_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "github",                 limit: 255
    t.string   "token",                  limit: 255
    t.boolean  "suspended",                          default: false
    t.string   "name",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "comments", "users", name: "comments_user_id_fk"
  add_foreign_key "dependencies", "projects", column: "master_project_id", name: "dependencies_master_project_id_fk"
  add_foreign_key "dependencies", "projects", column: "sub_project_id", name: "dependencies_sub_project_id_fk"
  add_foreign_key "installations", "servers", name: "installations_server_id_fk", on_delete: :cascade
  add_foreign_key "review_answers", "review_questions"
  add_foreign_key "review_answers", "reviews"
  add_foreign_key "review_questions", "review_sections"
  add_foreign_key "reviews", "projects"
  add_foreign_key "reviews", "users", column: "reviewer_id"
end
