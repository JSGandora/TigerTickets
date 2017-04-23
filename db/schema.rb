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

ActiveRecord::Schema.define(version: 20170423211904) do

  create_table "buy_requests", force: :cascade do |t|
    t.string   "netid"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "show_id"
    t.string   "email_token"
    t.index ["email_token"], name: "index_buy_requests_on_email_token", unique: true
    t.index ["show_id"], name: "index_buy_requests_on_show_id"
  end

  create_table "email_histories", force: :cascade do |t|
    t.integer  "sell_request_id"
    t.integer  "buy_request_id"
    t.string   "status"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["buy_request_id"], name: "index_email_histories_on_buy_request_id"
    t.index ["sell_request_id"], name: "index_email_histories_on_sell_request_id"
  end

  create_table "sell_requests", force: :cascade do |t|
    t.string   "netid"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "show_id"
    t.string   "email_token"
    t.index ["email_token"], name: "index_sell_requests_on_email_token", unique: true
    t.index ["show_id"], name: "index_sell_requests_on_show_id"
  end

  create_table "shows", force: :cascade do |t|
    t.string   "title"
    t.datetime "time"
    t.string   "location"
    t.string   "group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "img"
    t.index ["title", "time", "location", "group"], name: "index_shows_on_title_and_time_and_location_and_group", unique: true
  end

end
