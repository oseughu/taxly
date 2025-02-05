require_relative '../../lib/tax_calculator'
require_relative '../../lib/tax_config' # Ensure our config is loaded

RSpec.describe TaxCalculator do
  let(:spanish_vat) { TaxConfig.spanish_vat }

  describe ".calculate" do
    context "when product_type is :good" do
      context "buyer in Spain" do
        subject do
          TaxCalculator.calculate(
            product_type: :good,
            price: 100.0,
            buyer_country: "Spain",
            buyer_type: :individual
          )
        end

        it "applies Spanish VAT for goods" do
          expect(subject[:transaction_type]).to eq("good")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(spanish_vat)
          expect(subject[:tax_amount]).to eq(100.0 * spanish_vat)
        end
      end

      context "buyer in EU (individual)" do
        subject do
          TaxCalculator.calculate(
            product_type: :good,
            price: 100.0,
            buyer_country: "France",
            buyer_type: :individual
          )
        end

        it "applies local VAT for goods" do
          expected_rate = TaxConfig.local_vat_for("France")
          expect(subject[:transaction_type]).to eq("good")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(expected_rate)
          expect(subject[:tax_amount]).to eq(100.0 * expected_rate)
        end
      end

      context "buyer in EU (company)" do
        subject do
          TaxCalculator.calculate(
            product_type: :good,
            price: 100.0,
            buyer_country: "Germany",
            buyer_type: :company
          )
        end

        it "applies reverse charge" do
          expect(subject[:transaction_type]).to eq("reverse charge")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(0.0)
          expect(subject[:tax_amount]).to eq(0.0)
        end
      end

      context "buyer outside EU" do
        subject do
          TaxCalculator.calculate(
            product_type: :good,
            price: 100.0,
            buyer_country: "USA",
            buyer_type: :individual
          )
        end

        it "marks the transaction as export" do
          expect(subject[:transaction_type]).to eq("export")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(0.0)
          expect(subject[:tax_amount]).to eq(0.0)
        end
      end
    end

    context "when product_type is :digital" do
      context "buyer in Spain" do
        subject do
          TaxCalculator.calculate(
            product_type: :digital,
            price: 100.0,
            buyer_country: "Spain",
            buyer_type: :individual
          )
        end

        it "applies Spanish VAT for digital services" do
          expect(subject[:transaction_type]).to eq("service")
          expect(subject[:transaction_subtype]).to eq("digital")
          expect(subject[:tax_rate]).to eq(spanish_vat)
          expect(subject[:tax_amount]).to eq(100.0 * spanish_vat)
        end
      end

      context "buyer in EU (individual)" do
        subject do
          TaxCalculator.calculate(
            product_type: :digital,
            price: 100.0,
            buyer_country: "Italy",
            buyer_type: :individual
          )
        end

        it "applies local VAT for digital services" do
          expected_rate = TaxConfig.local_vat_for("Italy")
          expect(subject[:transaction_type]).to eq("service")
          expect(subject[:transaction_subtype]).to eq("digital")
          expect(subject[:tax_rate]).to eq(expected_rate)
          expect(subject[:tax_amount]).to eq(100.0 * expected_rate)
        end
      end

      context "buyer in EU (company)" do
        subject do
          TaxCalculator.calculate(
            product_type: :digital,
            price: 100.0,
            buyer_country: "France",
            buyer_type: :company
          )
        end

        it "applies reverse charge" do
          expect(subject[:transaction_type]).to eq("reverse charge")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(0.0)
          expect(subject[:tax_amount]).to eq(0.0)
        end
      end

      context "buyer outside EU" do
        subject do
          TaxCalculator.calculate(
            product_type: :digital,
            price: 100.0,
            buyer_country: "Canada",
            buyer_type: :individual
          )
        end

        it "applies no tax for digital services" do
          expect(subject[:transaction_type]).to eq("service")
          expect(subject[:transaction_subtype]).to eq("digital")
          expect(subject[:tax_rate]).to eq(0.0)
          expect(subject[:tax_amount]).to eq(0.0)
        end
      end
    end

    context "when product_type is :onsite" do
      context "service provided in Spain" do
        subject do
          TaxCalculator.calculate(
            product_type: :onsite,
            price: 200.0,
            buyer_country: "USA",
            buyer_type: :company,
            service_location: "Spain"
          )
        end

        it "applies Spanish VAT for onsite services" do
          expect(subject[:transaction_type]).to eq("service")
          expect(subject[:transaction_subtype]).to eq("onsite")
          expect(subject[:tax_rate]).to eq(spanish_vat)
          expect(subject[:tax_amount]).to eq(200.0 * spanish_vat)
        end
      end

      context "service provided in EU for an individual buyer" do
        subject do
          TaxCalculator.calculate(
            product_type: :onsite,
            price: 200.0,
            buyer_country: "USA",
            buyer_type: :individual,
            service_location: "Germany"
          )
        end

        it "applies local VAT for onsite services" do
          expected_rate = TaxConfig.local_vat_for("Germany")
          expect(subject[:transaction_type]).to eq("service")
          expect(subject[:transaction_subtype]).to eq("onsite")
          expect(subject[:tax_rate]).to eq(expected_rate)
          expect(subject[:tax_amount]).to eq(200.0 * expected_rate)
        end
      end

      context "service provided in EU for a company buyer" do
        subject do
          TaxCalculator.calculate(
            product_type: :onsite,
            price: 200.0,
            buyer_country: "Canada",
            buyer_type: :company,
            service_location: "France"
          )
        end

        it "applies reverse charge" do
          expect(subject[:transaction_type]).to eq("reverse charge")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(0.0)
          expect(subject[:tax_amount]).to eq(0.0)
        end
      end

      context "service provided outside EU" do
        subject do
          TaxCalculator.calculate(
            product_type: :onsite,
            price: 200.0,
            buyer_country: "Spain",
            buyer_type: :individual,
            service_location: "USA"
          )
        end

        it "marks the transaction as export (no tax)" do
          expect(subject[:transaction_type]).to eq("export")
          expect(subject[:transaction_subtype]).to be_nil
          expect(subject[:tax_rate]).to eq(0.0)
          expect(subject[:tax_amount]).to eq(0.0)
        end
      end

      context "missing service_location" do
        it "raises an error" do
          expect {
            TaxCalculator.calculate(
              product_type: :onsite,
              price: 200.0,
              buyer_country: "Spain",
              buyer_type: :individual
            )
          }.to raise_error(ArgumentError, /service location is required for onsite services/)
        end
      end
    end

    context "when an invalid product_type is provided" do
      it "raises an error" do
        expect {
          TaxCalculator.calculate(
            product_type: :invalid,
            price: 100.0,
            buyer_country: "Spain",
            buyer_type: :individual
          )
        }.to raise_error(ArgumentError, /Invalid product type/)
      end
    end
  end
end
