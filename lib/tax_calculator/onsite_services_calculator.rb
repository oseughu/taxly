require_relative "base_calculator"
require_relative "../tax_rules"

module TaxCalculator
  class OnsiteServicesCalculator < BaseCalculator
    # For onsite services, the rule key is "onsite"
    def tax_rule_key
      "onsite"
    end

    # Here we match based on the service location (and buyer type).
    def tax_rule_attributes
      { service_location:, buyer_type: }
    end

    # For local VAT, we use the service location rather than the buyer's country.
    def local_vat_target
      service_location
    end
  end
end
