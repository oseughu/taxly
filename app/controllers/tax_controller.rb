class TaxController < ApplicationController
  # Disable CSRF protection for API endpoints
  # (just because it's a test, I'll ensure proper security measures in production)
  skip_before_action :verify_authenticity_token

  def calculate
    product_type   = params[:product_type]&.to_sym
    price          = params[:price].to_f
    buyer_country  = params[:buyer_country]
    buyer_type     = params[:buyer_type]&.to_sym
    service_location = params[:service_location]

    # Validate mandatory parameters
    unless product_type && price && buyer_country && buyer_type
      render json: { error: "Missing required parameters" }, status: :bad_request and return
    end

    begin
      result = TaxCalculator.calculate(
        product_type:,
        price:,
        buyer_country:,
        buyer_type:,
        service_location:
      )
      render json: result, status: :ok
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end
  end
end
