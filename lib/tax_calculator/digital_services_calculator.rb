require_relative "base_calculator"

module TaxCalculator
  class DigitalServicesCalculator < BaseCalculator
    def calculate
      transaction, tax_rate = case
      when buyer_country == "Spain"
        [ [ "service", "digital" ], spanish_vat ]
      when in_eu?(buyer_country) && buyer_type == :individual
        [ [ "service", "digital" ], local_vat_for(buyer_country) ]
      when in_eu?(buyer_country) && buyer_type == :company
        [ "reverse charge", 0.0 ]
      else
        [ "export", 0.0 ]
      end

      tax_amount = price * tax_rate
      { transaction_type: transaction, tax_rate:, tax_amount: }
    end
  end
end
