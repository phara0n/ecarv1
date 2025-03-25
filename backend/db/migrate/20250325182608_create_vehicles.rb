class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :brand
      t.string :model
      t.integer :year
      t.string :license_plate
      t.string :vin
      t.integer :current_mileage
      t.float :average_daily_usage

      t.timestamps
    end
  end
end
