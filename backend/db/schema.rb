# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_25_182624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "repair_id", null: false
    t.decimal "amount"
    t.string "payment_status"
    t.string "pdf_document"
    t.decimal "vat_amount"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repair_id"], name: "index_invoices_on_repair_id"
  end

  create_table "repairs", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.text "description"
    t.date "start_date"
    t.date "completion_date"
    t.decimal "cost"
    t.string "status"
    t.string "mechanic"
    t.text "parts_used"
    t.float "labor_hours"
    t.date "next_service_estimate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_id"], name: "index_repairs_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "brand"
    t.string "model"
    t.integer "year"
    t.string "license_plate"
    t.string "vin"
    t.integer "current_mileage"
    t.float "average_daily_usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_vehicles_on_customer_id"
  end

  add_foreign_key "invoices", "repairs"
  add_foreign_key "repairs", "vehicles"
  add_foreign_key "vehicles", "customers"
end
