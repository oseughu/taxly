require_relative "../tax_config"

module TaxCalculator
  class BaseCalculator
    attr_reader :price, :buyer_country, :buyer_type, :service_location

    def initialize(price:, buyer_country:, buyer_type:, service_location: nil)
      @price = price
      @buyer_country = buyer_country
      @buyer_type = buyer_type
      @service_location = service_location
    end

    def in_eu?(country)
      TaxConfig.eu_countries.include?(country)
    end

    def local_vat_for(country)
      TaxConfig.local_vat_for(country).to_f
    end

    def spanish_vat
      TaxConfig.spanish_vat.to_f
    end

    # This is the shared calculate method that uses the abstract methods below.
    def calculate
      action = TaxRules.rule_for(tax_rule_key, tax_rule_attributes)
      raise "No rule matched for #{tax_rule_key} services" unless action

      transaction_type    = action["transaction_type"]
      transaction_subtype = action["transaction_subtype"]
      vat_config          = action["vat"]

      tax_rate = case vat_config
      when Numeric       then vat_config
      when "spanish_vat" then spanish_vat
      when "local_vat"   then local_vat_for(local_vat_target)
      else 0.00
      end

      tax_amount = price * tax_rate
      {
        transaction_type:    transaction_type,
        transaction_subtype: transaction_subtype,
        tax_rate:            tax_rate,
        tax_amount:          tax_amount.to_f
      }
    end

    # Abstract methods – subclasses must override these.
    def tax_rule_key
      raise NotImplementedError, "Subclasses must implement tax_rule_key"
    end

    def tax_rule_attributes
      raise NotImplementedError, "Subclasses must implement tax_rule_attributes"
    end

    def local_vat_target
      raise NotImplementedError, "Subclasses must implement local_vat_target"
    end
  end
end
