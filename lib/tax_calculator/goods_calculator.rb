require_relative "base_calculator"
require_relative "../tax_rules"

module TaxCalculator
  class GoodsCalculator < BaseCalculator
    # For goods, the rule key is "good"
    def tax_rule_key
      "good"
    end

    # The matching attributes for goods are also based on the buyer's country and type.
    def tax_rule_attributes
      { buyer_country:, buyer_type: }
    end

    # The local VAT lookup again uses the buyer's country.
    def local_vat_target
      buyer_country
    end
  end
end
