class Invoice < ApplicationRecord
  belongs_to :repair
  belongs_to :customer
  
  has_one_attached :pdf_file
  
  enum payment_status: { unpaid: 0, partial: 1, paid: 2 }
  enum payment_method: { cash: 0, credit_card: 1, bank_transfer: 2 }
  
  # Validations
  validates :invoice_number, presence: true, uniqueness: true
  validates :amount, :tax_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :issue_date, presence: true
  
  before_validation :set_invoice_number, :calculate_tax, on: :create
  
  # Tunisian VAT is 19%
  VAT_RATE = 0.19
  
  def total_amount
    amount + tax_amount
  end
  
  def total_amount_with_currency
    "#{total_amount} #{I18n.t('number.currency.format.unit')}"
  end
  
  # Generate sequential invoice number according to Tunisian "Facturation Normalisée" standards
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
    # Create a temporary path for the invoice PDF
    pdf_path = Rails.root.join('tmp', "invoice_#{invoice_number.gsub('/', '_')}.pdf")
    
    # Generate PDF using Prawn gem
    Prawn::Document.generate(pdf_path) do |pdf|
      # Add company logo
      # pdf.image Rails.root.join('app', 'assets', 'images', 'logo.png'), width: 150, position: :center
      
      pdf.text "eCar Garage", align: :center, size: 20, style: :bold
      pdf.move_down 10
      pdf.text "Facture Normalisée", align: :center, style: :bold
      pdf.move_down 20
      
      # Invoice details
      pdf.text "Facture N°: #{invoice_number}", size: 12, style: :bold
      pdf.text "Date: #{issue_date.strftime('%d/%m/%Y')}"
      pdf.move_down 10
      
      # Customer details
      customer_name = customer.full_name
      pdf.text "Client: #{customer_name}"
      pdf.text "Adresse: #{customer.address}" if customer.address.present?
      pdf.text "Téléphone: #{customer.phone}" if customer.phone.present?
      pdf.text "Email: #{customer.email}" if customer.email.present?
      pdf.move_down 10
      
      # Vehicle details
      vehicle = repair.vehicle
      pdf.text "Véhicule: #{vehicle.brand} #{vehicle.model} (#{vehicle.year})"
      pdf.text "Immatriculation: #{vehicle.license_plate}"
      pdf.text "Kilométrage: #{vehicle.current_mileage} km"
      pdf.move_down 20
      
      # Repair details
      pdf.text "Détails de la réparation:", style: :bold
      pdf.text repair.description
      pdf.move_down 20
      
      # Create a table for the invoice items
      items = []
      items << ["Description", "Montant HT (TND)"]
      items << ["Réparation", sprintf("%.3f", amount)]
      
      pdf.table(items, width: pdf.bounds.width) do |t|
        t.row(0).font_style = :bold
        t.columns(1).align = :right
        t.row(0).background_color = "DDDDDD"
      end
      
      pdf.move_down 10
      
      # Summary table
      summary = []
      summary << ["Montant HT", "TVA (19%)", "Montant TTC"]
      summary << [
        sprintf("%.3f TND", amount),
        sprintf("%.3f TND", tax_amount),
        sprintf("%.3f TND", total_amount)
      ]
      
      pdf.table(summary, width: pdf.bounds.width) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "DDDDDD"
        t.columns(0..2).align = :right
      end
      
      pdf.move_down 30
      
      # Payment information
      pdf.text "Statut de paiement: #{I18n.t("enums.invoice.payment_status.#{payment_status}")}"
      pdf.text "Méthode de paiement: #{I18n.t("enums.invoice.payment_method.#{payment_method}")}" if paid? || partial?
      
      # Footer with legal text for Tunisian invoices
      pdf.move_down 30
      pdf.text "Conformément à l'article 18 du code de la TVA", size: 8
      pdf.text "Identifiant Fiscal: 123456789", size: 8
      pdf.text "Registre de Commerce: B987654321", size: 8
      
      # Add QR code for Tunisian digital verification (placeholder)
      # pdf.image StringIO.new(generate_qr_code), at: [pdf.bounds.right - 50, 50], width: 50
    end
    
    # Attach the generated PDF to the invoice
    self.pdf_file.attach(
      io: File.open(pdf_path),
      filename: "facture_#{invoice_number.gsub('/', '_')}.pdf",
      content_type: 'application/pdf'
    )
    
    # Remove the temporary file
    File.delete(pdf_path) if File.exist?(pdf_path)
  end

  private
  
  def set_invoice_number
    self.invoice_number ||= self.class.generate_invoice_number
  end
  
  def calculate_tax
    self.tax_amount ||= (amount * VAT_RATE).round(3)
  end
  
  def generate_qr_code
    # Placeholder for QR code generation based on Tunisian requirements
    # This would generate a QR code with invoice details according to specifications
    # RQrcode::QRCode.new(qr_data).as_png(size: 100).to_s
  end
end
