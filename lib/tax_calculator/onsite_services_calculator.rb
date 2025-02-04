require_relative "base_calculator"

module TaxCalculator
  class OnsiteServicesCalculator < BaseCalculator
    def calculate
      transaction, tax_rate = case
      when service_location == "Spain"
        [ [ "service", "onsite" ], spanish_vat ]
      when in_eu?(service_location) && buyer_type == :individual
        [ [ "service", "onsite" ], local_vat_for(service_location) ]
      when in_eu?(service_location) && buyer_type == :company
        [ "reverse charge", 0.0 ]
      else
        [ "export", 0.0 ]
      end

      tax_amount = price * tax_rate
      { transaction_type: transaction, tax_rate:, tax_amount: }
    end
  end
end
