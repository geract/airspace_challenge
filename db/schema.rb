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

ActiveRecord::Schema[8.0].define(version: 2026_01_01_000003) do
  create_table "alerts", force: :cascade do |t|
    t.integer "shipment_id", null: false
    t.string "kind", null: false
    t.string "message", null: false
    t.datetime "acknowledged_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shipment_id", "kind"], name: "index_alerts_on_shipment_id_and_kind"
    t.index ["shipment_id"], name: "index_alerts_on_shipment_id"
  end

  create_table "flights", force: :cascade do |t|
    t.string "number", null: false
    t.string "origin", null: false
    t.string "destination", null: false
    t.datetime "scheduled_arrival_at", null: false
    t.datetime "estimated_arrival_at"
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_flights_on_number", unique: true
  end

  create_table "shipments", force: :cascade do |t|
    t.string "reference", null: false
    t.string "consignee", null: false
    t.integer "flight_id", null: false
    t.string "status", default: "booked", null: false
    t.datetime "deliver_by", null: false
    t.integer "last_mile_minutes", default: 45, null: false
    t.string "destination_time_zone", default: "America/Los_Angeles", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deliver_by"], name: "index_shipments_on_deliver_by"
    t.index ["flight_id"], name: "index_shipments_on_flight_id"
    t.index ["reference"], name: "index_shipments_on_reference", unique: true
  end

  add_foreign_key "alerts", "shipments"
  add_foreign_key "shipments", "flights"
end
