class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.references :shipment, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :message, null: false
      t.datetime :acknowledged_at
      t.timestamps
    end
    add_index :alerts, [:shipment_id, :kind]
  end
end
