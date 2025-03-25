class InvoiceMailer < ApplicationMailer
  def invoice_created(invoice)
    @invoice = invoice
    @customer = invoice.customer
    @repair = invoice.repair
    @vehicle = @repair.vehicle
    
    # Set locale based on customer preference
    I18n.with_locale(@customer.preferred_locale || I18n.default_locale) do
      attachments["facture_#{@invoice.invoice_number.gsub('/', '_')}.pdf"] = @invoice.pdf_file.download if @invoice.pdf_file.attached?
      
      mail(
        to: @customer.email,
        subject: I18n.t('mailers.invoice.created.subject', invoice_number: @invoice.invoice_number)
      )
    end
  end
  
  def payment_updated(invoice)
    @invoice = invoice
    @customer = invoice.customer
    @status = I18n.t("enums.invoice.payment_status.#{@invoice.payment_status}")
    
    # Set locale based on customer preference
    I18n.with_locale(@customer.preferred_locale || I18n.default_locale) do
      mail(
        to: @customer.email,
        subject: I18n.t('mailers.invoice.payment_updated.subject', invoice_number: @invoice.invoice_number)
      )
    end
  end
  
  def payment_reminder(invoice)
    @invoice = invoice
    @customer = invoice.customer
    @days_overdue = (Date.today - @invoice.due_date).to_i
    
    # Set locale based on customer preference
    I18n.with_locale(@customer.preferred_locale || I18n.default_locale) do
      attachments["facture_#{@invoice.invoice_number.gsub('/', '_')}.pdf"] = @invoice.pdf_file.download if @invoice.pdf_file.attached?
      
      mail(
        to: @customer.email,
        subject: I18n.t('mailers.invoice.payment_reminder.subject', invoice_number: @invoice.invoice_number)
      )
    end
  end
end 