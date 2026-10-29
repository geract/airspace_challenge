class CreateShipments < ActiveRecord::Migration[8.0]
  def change
    create_table :shipments do |t|
      t.string :reference, null: false
      t.string :consignee, null: false
      t.references :flight, null: false, foreign_key: true
      t.string :status, null: false, default: "booked"
      t.datetime :deliver_by, null: false
      t.integer :last_mile_minutes, null: false, default: 45
      t.string :destination_time_zone, null: false, default: "America/Los_Angeles"
      t.timestamps
    end
    add_index :shipments, :reference, unique: true
    add_index :shipments, :deliver_by
  end
end
