class CreateRepairs < ActiveRecord::Migration[7.1]
  def change
    create_table :repairs do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.text :description
      t.date :start_date
      t.date :completion_date
      t.decimal :cost
      t.string :status
      t.string :mechanic
      t.text :parts_used
      t.float :labor_hours
      t.date :next_service_estimate

      t.timestamps
    end
  end
end
