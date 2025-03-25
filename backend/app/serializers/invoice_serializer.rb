class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :amount, :payment_status, :pdf_url, :payment_method
  
  belongs_to :repair
  
  def pdf_url
    if object.pdf_file.attached?
      Rails.application.routes.url_helpers.url_for(object.pdf_file)
    end
  end
end 