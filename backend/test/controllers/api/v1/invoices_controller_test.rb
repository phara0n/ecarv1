require 'test_helper'

module Api
  module V1
    class InvoicesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = customers(:admin)
        @customer = customers(:customer_one)
        @repair = repairs(:repair_one)
        @invoice = invoices(:one)
        @customer_invoice = invoices(:two)
        
        # Set up JWT tokens
        @admin_headers = { 'Authorization' => JsonWebToken.encode(customer_id: @admin.id) }
        @customer_headers = { 'Authorization' => JsonWebToken.encode(customer_id: @customer.id) }
      end
      
      test "should get index for admin" do
        get api_v1_invoices_url, headers: @admin_headers, as: :json
        assert_response :success
        
        response_body = JSON.parse(response.body)
        assert_not_empty response_body
      end
      
      test "should get index for customer" do
        get api_v1_invoices_url, headers: @customer_headers, as: :json
        assert_response :success
        
        response_body = JSON.parse(response.body)
        # Customer should only see their own invoices
        assert response_body.all? { |invoice| invoice["customer_id"] == @customer.id }
      end
      
      test "should create invoice" do
        assert_difference('Invoice.count') do
          post api_v1_invoices_url, 
            params: { 
              invoice: { 
                repair_id: @repair.id, 
                amount: 150.0, 
                customer_id: @customer.id,
                payment_status: 'unpaid', 
                date: Date.today
              } 
            }, 
            headers: @admin_headers, 
            as: :json
        end
        
        assert_response :created
      end
      
      test "should show invoice for admin" do
        get api_v1_invoice_url(@invoice), headers: @admin_headers, as: :json
        assert_response :success
        
        response_body = JSON.parse(response.body)
        assert_equal @invoice.id, response_body["id"]
      end
      
      test "should show invoice for customer if it's their invoice" do
        get api_v1_invoice_url(@customer_invoice), headers: @customer_headers, as: :json
        assert_response :success
        
        response_body = JSON.parse(response.body)
        assert_equal @customer_invoice.id, response_body["id"]
      end
      
      test "should not show invoice for customer if it's not their invoice" do
        get api_v1_invoice_url(@invoice), headers: @customer_headers, as: :json
        assert_response :forbidden
      end
      
      test "should update invoice" do
        patch api_v1_invoice_url(@invoice), 
          params: { invoice: { amount: 175.0 } }, 
          headers: @admin_headers, 
          as: :json
        assert_response :success
        
        @invoice.reload
        assert_equal 175.0, @invoice.amount
      end
      
      test "should not allow customer to update invoice" do
        patch api_v1_invoice_url(@customer_invoice), 
          params: { invoice: { amount: 175.0 } }, 
          headers: @customer_headers, 
          as: :json
        assert_response :forbidden
      end
      
      test "should destroy invoice" do
        assert_difference('Invoice.count', -1) do
          delete api_v1_invoice_url(@invoice), headers: @admin_headers, as: :json
        end
        
        assert_response :no_content
      end
      
      test "should not allow customer to destroy invoice" do
        assert_no_difference('Invoice.count') do
          delete api_v1_invoice_url(@customer_invoice), headers: @customer_headers, as: :json
        end
        
        assert_response :forbidden
      end
      
      test "should update invoice payment status" do
        patch mark_as_paid_api_v1_invoice_url(@invoice), headers: @admin_headers, as: :json
        assert_response :success
        
        @invoice.reload
        assert_equal 'paid', @invoice.payment_status
      end
      
      test "should not allow customer to update invoice payment status" do
        patch mark_as_paid_api_v1_invoice_url(@customer_invoice), headers: @customer_headers, as: :json
        assert_response :forbidden
      end
      
      test "should mark invoice as partially paid" do
        patch mark_as_partially_paid_api_v1_invoice_url(@invoice), 
          params: { amount_paid: 50.0 }, 
          headers: @admin_headers, 
          as: :json
        assert_response :success
        
        @invoice.reload
        assert_equal 'partially_paid', @invoice.payment_status
        assert_equal 50.0, @invoice.amount_paid
      end
      
      test "should mark invoice as cancelled" do
        patch mark_as_cancelled_api_v1_invoice_url(@invoice), headers: @admin_headers, as: :json
        assert_response :success
        
        @invoice.reload
        assert_equal 'cancelled', @invoice.payment_status
      end
      
      test "should generate pdf for invoice" do
        get generate_pdf_api_v1_invoice_url(@invoice), headers: @admin_headers, as: :json
        assert_response :success
        
        response_body = JSON.parse(response.body)
        assert_not_nil response_body["pdf_url"]
      end
      
      test "should allow customer to view their invoice pdf" do
        get generate_pdf_api_v1_invoice_url(@customer_invoice), headers: @customer_headers, as: :json
        assert_response :success
        
        response_body = JSON.parse(response.body)
        assert_not_nil response_body["pdf_url"]
      end
      
      test "should not allow customer to view other invoice pdf" do
        get generate_pdf_api_v1_invoice_url(@invoice), headers: @customer_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end 