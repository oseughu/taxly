require_relative "base_calculator"
require_relative "../tax_rules"

module TaxCalculator
  class DigitalServicesCalculator < BaseCalculator
    def calculate
      attributes = { buyer_country: buyer_country, buyer_type: buyer_type }
      action = TaxRules.rule_for("digital", attributes)
      raise "No rule matched for digital services" unless action

      transaction_type    = action["transaction_type"]
      transaction_subtype = action["transaction_subtype"]
      vat_config          = action["vat"]

      tax_rate = case vat_config
      when Numeric then vat_config
      when "spanish_vat" then spanish_vat
      when "local_vat" then local_vat_for(buyer_country)
      else 0.00
      end

      tax_amount = format("%.2f", (price * tax_rate).round(2))
      {
        transaction_type: transaction_type,
        transaction_subtype: transaction_subtype,
        tax_rate: tax_rate,
        tax_amount: tax_amount.to_f
      }
    end
  end
end
