require 'test_helper'

module Api
  module V1
    class InvoicesControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      
      setup do
        @admin = users(:admin)
        @customer = users(:customer)
        @repair = repairs(:repair_one)
        @invoice = invoices(:invoice_one)
        
        # Set up JWT tokens
        @admin_headers = { 
          'Authorization' => "Bearer #{generate_jwt_token(@admin)}",
          'Content-Type' => 'application/json'
        }
        
        @customer_headers = { 
          'Authorization' => "Bearer #{generate_jwt_token(@customer)}",
          'Content-Type' => 'application/json'
        }
      end
      
      test "should get index for admin" do
        get api_v1_invoices_url, headers: @admin_headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_not_nil json_response['invoices']
        assert_not_nil json_response['meta']
      end
      
      test "should get index for customer with their own invoices only" do
        get api_v1_invoices_url, headers: @customer_headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_not_nil json_response['invoices']
        
        # Verify that only customer's invoices are returned
        invoice_ids = json_response['invoices'].map { |i| i['id'] }
        customer_invoice_ids = Invoice.where(customer_id: @customer.customer.id).pluck(:id)
        assert_equal invoice_ids.sort, customer_invoice_ids.sort
      end
      
      test "should create invoice" do
        assert_difference('Invoice.count') do
          post api_v1_invoices_url, 
            params: { 
              invoice: { 
                repair_id: @repair.id, 
                customer_id: @customer.customer.id,
                amount: 500.00,
                issue_date: Date.today
              } 
            }.to_json,
            headers: @admin_headers
        end
        
        assert_response :created
        json_response = JSON.parse(response.body)
        assert_not_nil json_response['id']
        assert_not_nil json_response['invoice_number']
      end
      
      test "should show invoice" do
        get api_v1_invoice_url(@invoice), headers: @admin_headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_equal @invoice.id, json_response['id']
        assert_equal @invoice.amount.to_s, json_response['amount']
      end
      
      test "should update invoice" do
        new_amount = 600.00
        
        patch api_v1_invoice_url(@invoice), 
          params: { invoice: { amount: new_amount } }.to_json,
          headers: @admin_headers
          
        assert_response :success
        
        @invoice.reload
        assert_equal new_amount, @invoice.amount
      end
      
      test "should update payment status" do
        patch update_payment_api_v1_invoice_url(@invoice), 
          params: { 
            payment: { 
              payment_method: 'cash',
              paid_amount: @invoice.amount
            } 
          }.to_json,
          headers: @admin_headers
          
        assert_response :success
        
        @invoice.reload
        assert_equal 'paid', @invoice.payment_status
        assert_equal 'cash', @invoice.payment_method
        assert_equal @invoice.amount, @invoice.paid_amount
      end
      
      test "should handle partial payment" do
        patch update_payment_api_v1_invoice_url(@invoice), 
          params: { 
            payment: { 
              payment_method: 'credit_card',
              paid_amount: @invoice.amount / 2
            } 
          }.to_json,
          headers: @admin_headers
          
        assert_response :success
        
        @invoice.reload
        assert_equal 'partial', @invoice.payment_status
        assert_equal 'credit_card', @invoice.payment_method
        assert_equal @invoice.amount / 2, @invoice.paid_amount
      end
      
      test "should download invoice" do
        # Ensure invoice has a PDF attached
        @invoice.generate_pdf
        
        get download_api_v1_invoice_url(@invoice), headers: @admin_headers
        assert_response :redirect
      end
      
      test "should destroy invoice" do
        assert_difference('Invoice.count', -1) do
          delete api_v1_invoice_url(@invoice), headers: @admin_headers
        end
        
        assert_response :no_content
      end
      
      test "should not allow customer to create invoice" do
        assert_no_difference('Invoice.count') do
          post api_v1_invoices_url, 
            params: { 
              invoice: { 
                repair_id: @repair.id, 
                customer_id: @customer.customer.id,
                amount: 500.00
              } 
            }.to_json,
            headers: @customer_headers
        end
        
        assert_response :forbidden
      end
      
      test "should not allow customer to delete invoice" do
        assert_no_difference('Invoice.count') do
          delete api_v1_invoice_url(@invoice), headers: @customer_headers
        end
        
        assert_response :forbidden
      end
      
      private
      
      def generate_jwt_token(user)
        JWT.encode(
          { 
            sub: user.id,
            iat: Time.current.to_i,
            exp: 24.hours.from_now.to_i
          },
          Rails.application.credentials.secret_key_base
        )
      end
    end
  end
end 