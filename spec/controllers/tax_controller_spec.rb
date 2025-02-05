require 'rails_helper'

RSpec.describe "Taxly API", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  describe "POST /calculate" do
    context "with valid parameters" do
      context "for physical goods" do
        let(:payload) {
          {
            product_type: "good",
            price: 100.0,
            buyer_country: "Spain",
            buyer_type: "individual"
          }.to_json
        }

        it "returns the tax calculation for physical goods" do
          post "/calculate", params: payload, headers: headers
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["transaction_type"]).to eq("good")
          expect(json["transaction_subtype"]).to be_nil
          expect(json["tax_rate"]).to eq(TaxConfig.spanish_vat)
          expect(json["tax_amount"]).to eq(100.0 * TaxConfig.spanish_vat)
        end
      end

      context "for digital services" do
        let(:payload) {
          {
            product_type: "digital",
            price: 100.0,
            buyer_country: "Italy",
            buyer_type: "individual"
          }.to_json
        }

        it "returns the tax calculation for digital services" do
          post "/calculate", params: payload, headers: headers
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["transaction_type"]).to eq("service")
          expect(json["transaction_subtype"]).to eq("digital")
          expected_rate = TaxConfig.local_vat_for("Italy")
          expect(json["tax_rate"]).to eq(expected_rate)
          expect(json["tax_amount"]).to eq(100.0 * expected_rate)
        end
      end

      context "for onsite services" do
        let(:payload) {
          {
            product_type: "onsite",
            price: 200.0,
            buyer_country: "USA",
            buyer_type: "company",
            service_location: "Spain"
          }.to_json
        }

        it "returns the tax calculation for onsite services" do
          post "/calculate", params: payload, headers: headers
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["transaction_type"]).to eq("service")
          expect(json["transaction_subtype"]).to eq("onsite")
          expect(json["tax_rate"]).to eq(TaxConfig.spanish_vat)
          expect(json["tax_amount"]).to eq(200.0 * TaxConfig.spanish_vat)
        end
      end
    end

    context "with missing required parameters" do
      let(:payload) { {}.to_json }

      it "returns 400 Bad Request" do
        post "/calculate", params: payload, headers: headers
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Missing required parameters")
      end
    end

    context "with an invalid product_type" do
      let(:payload) {
        {
          product_type: "invalid",
          price: 100.0,
          buyer_country: "Spain",
          buyer_type: "individual"
        }.to_json
      }

      it "returns 422 Unprocessable Entity" do
        post "/calculate", params: payload, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to match(/Invalid product type/)
      end
    end

    context "with missing service_location for an onsite service" do
      let(:payload) {
        {
          product_type: "onsite",
          price: 200.0,
          buyer_country: "Spain",
          buyer_type: "individual"
        }.to_json
      }

      it "returns 422 Unprocessable Entity" do
        post "/calculate", params: payload, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to match(/service location is required for onsite services/)
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(TaxCalculator).to receive(:calculate).and_raise(StandardError.new("Unexpected error"))
      end

      let(:payload) {
        {
          product_type: "good",
          price: 100.0,
          buyer_country: "Spain",
          buyer_type: "individual"
        }.to_json
      }

      it "returns 500 Internal Server Error" do
        post "/calculate", params: payload, headers: headers
        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        expect(json["error"]).to match(/An unexpected error occurred/)
      end
    end
  end
end
