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

ActiveRecord::Schema.define(version: 20150710074443) do

  create_table "companies", force: :cascade do |t|
    t.string   "company_name", limit: 255
    t.string   "postal_code",  limit: 255
    t.string   "address1",     limit: 255
    t.string   "address2",     limit: 255
    t.string   "address3",     limit: 255
    t.string   "address4",     limit: 255
    t.string   "tel",          limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.integer  "company_id",    limit: 4
    t.string   "job_name",      limit: 255
    t.text     "work_address",  limit: 65535
    t.string   "category",      limit: 255
    t.string   "job_type",      limit: 255
    t.text     "job_info",      limit: 65535
    t.text     "requirement",   limit: 65535
    t.string   "work_time",     limit: 255
    t.text     "salary",        limit: 65535
    t.string   "holiday",       limit: 255
    t.text     "treatment",     limit: 65535
    t.string   "capture_url",   limit: 255
    t.string   "site",          limit: 255
    t.datetime "update_time"
    t.datetime "register_time"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "jobs", ["company_id"], name: "index_jobs_on_company_id", using: :btree

  add_foreign_key "jobs", "companies"
end
