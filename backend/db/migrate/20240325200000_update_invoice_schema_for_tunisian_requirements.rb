class UpdateInvoiceSchemaForTunisianRequirements < ActiveRecord::Migration[7.0]
  def change
    # Add new fields only if they don't exist
    change_table :invoices do |t|
      # Add invoice number if it doesn't exist
      unless column_exists?(:invoices, :invoice_number)
        t.string :invoice_number, null: false      # Sequential numbering
        # Add index for invoice_number searches
        add_index :invoices, :invoice_number, unique: true
      end
      
      # Add dates if they don't exist
      unless column_exists?(:invoices, :issue_date)
        t.date :issue_date, null: false, default: -> { 'CURRENT_DATE' }
      end
      
      unless column_exists?(:invoices, :due_date)
        t.date :due_date
      end
      
      # The payment_status column already exists but we want to change it to integer
      # First check if it's already an integer
      if column_exists?(:invoices, :payment_status) && 
         !column_is_integer?(:invoices, :payment_status)
        t.remove :payment_status
        t.integer :payment_status, default: 0  # 0=unpaid, 1=partial, 2=paid
      end
      
      # Only add payment_method if it doesn't exist
      unless column_exists?(:invoices, :payment_method)
        t.integer :payment_method  # 0=cash, 1=credit_card, 2=bank_transfer
      end
      
      # Add customer reference if it doesn't exist
      unless column_exists?(:invoices, :customer_id)
        t.references :customer, foreign_key: true
      end
      
      # Add fields for partial payments tracking if they don't exist
      unless column_exists?(:invoices, :paid_amount)
        t.decimal :paid_amount, precision: 10, scale: 2, default: 0
      end
      
      unless column_exists?(:invoices, :payment_date)
        t.date :payment_date
      end
    end
  end
  
  # Helper method to check if a column is an integer
  def column_is_integer?(table, column)
    column_type = connection.columns(table).find { |c| c.name == column.to_s }&.type
    column_type == :integer
  end
end 