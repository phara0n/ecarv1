class InvoiceDetailSerializer < InvoiceSerializer
  # Add Tunisian fiscal information
  attributes :fiscal_id, :commercial_registry, :vat_rate
  
  # Include customer and repair details for the invoice
  has_one :customer
  has_one :repair
  
  # Include vehicle information
  has_one :vehicle, through: :repair
  
  def vat_rate
    "19%" # Tunisian VAT rate
  end
  
  # Format amounts according to Tunisian standards (3 decimal places)
  def amount
    sprintf("%.3f", object.amount)
  end
  
  def tax_amount
    sprintf("%.3f", object.tax_amount)
  end
  
  def total_amount
    sprintf("%.3f", object.total_amount)
  end
  
  def paid_amount
    sprintf("%.3f", object.paid_amount || 0)
  end
end 