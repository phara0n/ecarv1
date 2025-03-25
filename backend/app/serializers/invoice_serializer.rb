class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :amount, :payment_status, :pdf_document, :vat_amount, 
             :payment_method, :total_with_vat
  
  belongs_to :repair
  
  def pdf_url
    if object.pdf.attached?
      Rails.application.routes.url_helpers.url_for(object.pdf)
    end
  end
end 