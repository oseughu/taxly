require_relative "base_calculator"
require_relative "../tax_rules"

module TaxCalculator
  class OnsiteServicesCalculator < BaseCalculator
    def calculate
      attributes = { service_location: service_location, buyer_type: buyer_type }
      action = TaxRules.rule_for("onsite", attributes)
      raise "No rule matched for onsite services" unless action

      transaction_type    = action["transaction_type"]
      transaction_subtype = action["transaction_subtype"]
      vat_config          = action["vat"]

      tax_rate = case vat_config
      when Numeric then vat_config
      when "spanish_vat" then spanish_vat
      when "local_vat" then local_vat_for(service_location)
      else 0.0
      end

      tax_amount = price * tax_rate
      {
        transaction_type: transaction_type,
        transaction_subtype: transaction_subtype,
        tax_rate: tax_rate,
        tax_amount: tax_amount
      }
    end
  end
end
