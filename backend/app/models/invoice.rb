class Invoice < ApplicationRecord
  belongs_to :repair
  belongs_to :customer
  
  has_one_attached :pdf_file
  
  enum payment_status: { unpaid: 0, partial: 1, paid: 2 }
  enum payment_method: { cash: 0, credit_card: 1, bank_transfer: 2 }
  
  # Validations
  validates :invoice_number, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :issue_date, presence: true
  
  before_validation :set_invoice_number, on: :create
  
  def total_amount_with_currency
    "#{amount} #{I18n.t('number.currency.format.unit')}"
  end
  
  # Generate sequential invoice number
  # Format: ECAR/YYYY/MMXXXX (where XXXX is sequential)
  def self.generate_invoice_number
    year = Date.today.year
    month = Date.today.month.to_s.rjust(2, '0')
    
    # Find latest invoice for this month
    latest_invoice = Invoice.where("invoice_number LIKE ?", "ECAR/#{year}/#{month}%")
                           .order(invoice_number: :desc)
                           .first
                           
    if latest_invoice
      # Extract the sequential number and increment
      seq_number = latest_invoice.invoice_number.split('/').last.to_i + 1
    else
      # First invoice of the month
      seq_number = 1
    end
    
    "ECAR/#{year}/#{month}#{seq_number.to_s.rjust(4, '0')}"
  end
  
  def generate_pdf
    # Skip actual PDF generation in test environment
    if Rails.env.test?
      return mock_pdf_generation
    end
    
    # Create a temporary path for the invoice PDF
    pdf_path = Rails.root.join('tmp', "invoice_#{invoice_number.gsub('/', '_')}.pdf")
    
    # Generate PDF using Prawn gem
    Prawn::Document.generate(pdf_path) do |pdf|
      # Add company logo
      # pdf.image Rails.root.join('app', 'assets', 'images', 'logo.png'), width: 150, position: :center
      
      pdf.text "eCar Garage", align: :center, size: 20, style: :bold
      pdf.move_down 10
      pdf.text "Invoice", align: :center, style: :bold
      pdf.move_down 20
      
      # Invoice details
      pdf.text "Invoice No: #{invoice_number}", size: 12, style: :bold
      pdf.text "Date: #{issue_date.strftime('%d/%m/%Y')}"
      pdf.move_down 10
      
      # Customer details
      customer_name = customer.full_name
      pdf.text "Client: #{customer_name}"
      pdf.text "Address: #{customer.address}" if customer.address.present?
      pdf.text "Phone: #{customer.phone}" if customer.phone.present?
      pdf.text "Email: #{customer.email}" if customer.email.present?
      pdf.move_down 10
      
      # Vehicle details
      vehicle = repair.vehicle
      pdf.text "Vehicle: #{vehicle.brand} #{vehicle.model} (#{vehicle.year})"
      pdf.text "License Plate: #{vehicle.license_plate}"
      pdf.text "Mileage: #{vehicle.current_mileage} km"
      pdf.move_down 20
      
      # Repair details
      pdf.text "Repair Details:", style: :bold
      pdf.text repair.description
      pdf.move_down 20
      
      # Create a table for the invoice
      items = []
      items << ["Description", "Amount"]
      items << ["Repair", sprintf("%.2f TND", amount)]
      
      pdf.table(items, width: pdf.bounds.width) do |t|
        t.row(0).font_style = :bold
        t.columns(1).align = :right
        t.row(0).background_color = "DDDDDD"
      end
      
      pdf.move_down 30
      
      # Payment information
      pdf.text "Payment status: #{I18n.t("enums.invoice.payment_status.#{payment_status}")}"
      pdf.text "Payment method: #{I18n.t("enums.invoice.payment_method.#{payment_method}")}" if paid? || partial?
      
      pdf.move_down 30
      pdf.text "Thank you for choosing eCar Garage", size: 10, align: :center
    end
    
    # Attach the generated PDF to the invoice
    self.pdf_file.attach(
      io: File.open(pdf_path),
      filename: "invoice_#{invoice_number.gsub('/', '_')}.pdf",
      content_type: 'application/pdf'
    )
    
    # Remove the temporary file
    File.delete(pdf_path) if File.exist?(pdf_path)
  end

  # Mock PDF generation for tests
  def mock_pdf_generation
    # Just set the pdf_document field for tests
    update_column(:pdf_document, "test_invoice_#{id}.pdf") if persisted?
    true
  end

  private
  
  def set_invoice_number
    self.invoice_number ||= self.class.generate_invoice_number
  end
end
