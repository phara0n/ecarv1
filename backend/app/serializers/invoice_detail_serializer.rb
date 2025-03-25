class InvoiceDetailSerializer < InvoiceSerializer
  # Include customer and repair details for the invoice
  has_one :customer
  has_one :repair
  
  # Include vehicle information
  has_one :vehicle, through: :repair
  
  # Format amounts with 2 decimal places
  def amount
    sprintf("%.2f", object.amount)
  end
  
  def paid_amount
    sprintf("%.2f", object.paid_amount || 0)
  end
  
  def remaining_amount
    if object.paid?
      "0.00"
    elsif object.partial?
      sprintf("%.2f", object.amount - (object.paid_amount || 0))
    else
      sprintf("%.2f", object.amount)
    end
  end
end 