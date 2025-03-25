class UpdateInvoiceSchemaForTunisianRequirements < ActiveRecord::Migration[7.0]
  def change
    # Update existing fields
    change_table :invoices do |t|
      # Add fields needed for Tunisian invoices
      t.string :invoice_number, null: false      # For "Facturation Normalisée" sequential numbering
      t.decimal :tax_amount, precision: 10, scale: 3, default: 0  # Tunisian VAT amount (19%)
      t.date :issue_date, null: false, default: -> { 'CURRENT_DATE' }
      t.date :due_date
      
      # Change payment_status to integer for enum
      t.remove :payment_status
      t.integer :payment_status, default: 0  # 0=unpaid, 1=partial, 2=paid
      
      # Add payment_method
      t.integer :payment_method  # 0=cash, 1=credit_card, 2=bank_transfer
      
      # Add customer reference (direct relationship for Tunisian invoice requirements)
      t.references :customer, foreign_key: true
      
      # Add fields for Tunisian fiscal requirements
      t.string :fiscal_id  # Identifiant Fiscal
      t.string :commercial_registry  # Registre de Commerce
      
      # Add fields for partial payments tracking (common in Tunisia)
      t.decimal :paid_amount, precision: 10, scale: 3, default: 0
      t.date :payment_date
    end
    
    # Add index for invoice_number searches
    add_index :invoices, :invoice_number, unique: true
  end
end 