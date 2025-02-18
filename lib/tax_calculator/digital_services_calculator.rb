require_relative "base_calculator"
require_relative "../tax_rules"

module TaxCalculator
  class DigitalServicesCalculator < BaseCalculator
    # For digital services, the rule key is "digital"
    def tax_rule_key
      "digital"
    end

    # The matching attributes for digital services come from the buyer's country and type.
    def tax_rule_attributes
      { buyer_country:, buyer_type: }
    end

    # When looking up the local VAT, we use the buyer's country.
    def local_vat_target
      buyer_country
    end
  end
end
