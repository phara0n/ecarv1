require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @customer = customers(:customer_one)
    @repair = repairs(:repair_one)
  end
  
  test "should create a valid invoice" do
    invoice = Invoice.new(
      customer: @customer,
      repair: @repair,
      amount: 500.00,
      issue_date: Date.today
    )
    
    assert invoice.valid?
    assert invoice.save
  end
  
  test "should not be valid without required fields" do
    # No customer
    invoice = Invoice.new(
      repair: @repair,
      amount: 500.00,
      issue_date: Date.today
    )
    assert_not invoice.valid?
    
    # No repair
    invoice = Invoice.new(
      customer: @customer,
      amount: 500.00,
      issue_date: Date.today
    )
    assert_not invoice.valid?
    
    # No amount
    invoice = Invoice.new(
      customer: @customer,
      repair: @repair,
      issue_date: Date.today
    )
    assert_not invoice.valid?
    
    # No issue date
    invoice = Invoice.new(
      customer: @customer,
      repair: @repair,
      amount: 500.00
    )
    assert_not invoice.valid?
  end
  
  test "should automatically generate invoice number" do
    invoice = Invoice.create(
      customer: @customer,
      repair: @repair,
      amount: 500.00,
      issue_date: Date.today
    )
    
    assert_not_nil invoice.invoice_number
    assert invoice.invoice_number.start_with?("ECAR/#{Date.today.year}/#{Date.today.month.to_s.rjust(2, '0')}")
  end
  
  test "should track payment status" do
    invoice = Invoice.create(
      customer: @customer,
      repair: @repair,
      amount: 500.00,
      issue_date: Date.today
    )
    
    # Default status is unpaid
    assert invoice.unpaid?
    
    # Update to partial payment
    invoice.update(payment_status: :partial, paid_amount: 250.00, payment_method: :cash)
    assert invoice.partial?
    assert_equal 250.00, invoice.paid_amount
    
    # Update to fully paid
    invoice.update(payment_status: :paid, paid_amount: 500.00)
    assert invoice.paid?
  end
  
  test "should format currency correctly" do
    invoice = Invoice.create(
      customer: @customer,
      repair: @repair,
      amount: 500.50,
      issue_date: Date.today
    )
    
    I18n.with_locale(:en) do
      assert_equal "500.50 USD", invoice.total_amount_with_currency
    end
    
    I18n.with_locale(:fr) do
      assert_equal "500.50 €", invoice.total_amount_with_currency
    end
    
    I18n.with_locale(:ar) do
      assert_equal "500.50 د.ت", invoice.total_amount_with_currency
    end
  end
  
  test "should generate PDF file" do
    invoice = Invoice.create(
      customer: @customer,
      repair: @repair,
      amount: 500.00,
      issue_date: Date.today
    )
    
    invoice.generate_pdf
    assert invoice.pdf_file.attached?
  end
end 