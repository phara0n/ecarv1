class UpdateInvoiceSchemaForTunisianRequirements < ActiveRecord::Migration[7.0]
  def change
    # Update existing fields
    change_table :invoices do |t|
      # Add simple invoice fields
      t.string :invoice_number, null: false      # Sequential numbering
      t.date :issue_date, null: false, default: -> { 'CURRENT_DATE' }
      t.date :due_date
      
      # Change payment_status to integer for enum
      t.remove :payment_status
      t.integer :payment_status, default: 0  # 0=unpaid, 1=partial, 2=paid
      
      # Add payment_method
      t.integer :payment_method  # 0=cash, 1=credit_card, 2=bank_transfer
      
      # Add customer reference
      t.references :customer, foreign_key: true
      
      # Add fields for partial payments tracking
      t.decimal :paid_amount, precision: 10, scale: 2, default: 0
      t.date :payment_date
    end
    
    # Add index for invoice_number searches
    add_index :invoices, :invoice_number, unique: true
  end
end 