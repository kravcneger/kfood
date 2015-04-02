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

ActiveRecord::Schema.define(version: 20140917102724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additions", force: true do |t|
    t.integer "organization_id",             null: false
    t.integer "addition_id",     default: 0
    t.string  "name",                        null: false
    t.integer "price"
    t.boolean "active"
  end

  create_table "categories", force: true do |t|
    t.integer "organization_id",             null: false
    t.integer "category_id",     default: 0
    t.boolean "active"
    t.string  "name"
    t.integer "ordering",                    null: false
  end

  create_table "orders", force: true do |t|
    t.integer  "organization_id",                            null: false
    t.string   "name",                                       null: false
    t.string   "contact_phone",   limit: 11,                 null: false
    t.string   "street",                                     null: false
    t.string   "house",                                      null: false
    t.json     "addition_info"
    t.datetime "time_order"
    t.text     "comment"
    t.json     "body",                                       null: false
    t.integer  "price",                                      null: false
    t.integer  "delivery",                                   null: false
    t.boolean  "viewed",                     default: false
    t.boolean  "notified",                   default: false
    t.integer  "status",          limit: 2,  default: 0
    t.cidr     "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.string   "name",                                   null: false
    t.text     "addresses"
    t.text     "contacts"
    t.text     "description"
    t.integer  "min_delivery"
    t.integer  "delivery"
    t.integer  "free_shipping"
    t.boolean  "active",                 default: false
    t.text     "additional_information"
    t.text     "map_code",               default: ""
    t.boolean  "published",              default: true
    t.text     "message_block"
    t.json     "social_networks"
    t.string   "notification_email",     default: ""
    t.string   "push_key1",              default: ""
    t.string   "push_key2",              default: ""
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "premature_notification", default: 1
  end

  add_index "organizations", ["email"], name: "index_organizations_on_email", unique: true, using: :btree
  add_index "organizations", ["reset_password_token"], name: "index_organizations_on_reset_password_token", unique: true, using: :btree

  create_table "products", force: true do |t|
    t.integer  "organization_id",                           null: false
    t.integer  "category_id",                               null: false
    t.integer  "addition_id"
    t.string   "name",                                      null: false
    t.text     "description"
    t.integer  "weight"
    t.integer  "calories"
    t.integer  "price",                         default: 0, null: false
    t.integer  "active",              limit: 2, default: 0
    t.datetime "locked_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "schedules", force: true do |t|
    t.integer "organization_id",           null: false
    t.integer "day",             limit: 2, null: false
    t.boolean "is_holiday"
    t.string  "first_time",      limit: 5
    t.string  "second_time",     limit: 5
  end

end
