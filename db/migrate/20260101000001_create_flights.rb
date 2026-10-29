class CreateFlights < ActiveRecord::Migration[8.0]
  def change
    create_table :flights do |t|
      t.string :number, null: false
      t.string :origin, null: false
      t.string :destination, null: false
      t.datetime :scheduled_arrival_at, null: false
      t.datetime :estimated_arrival_at
      t.string :status, null: false, default: "scheduled"
      t.timestamps
    end
    add_index :flights, :number, unique: true
  end
end
