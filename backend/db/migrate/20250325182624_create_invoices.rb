class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :repair, null: false, foreign_key: true
      t.decimal :amount
      t.string :payment_status
      t.string :pdf_document
      t.decimal :vat_amount
      t.string :payment_method

      t.timestamps
    end
  end
end
