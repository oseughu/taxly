require "yaml"
require_relative "tax_config"

module TaxRules
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "tax_rules.yml"))

  # Returns the first matching rule's action for a given product type and attribute hash.
  def self.rule_for(product_type, attributes)
    rules = CONFIG[product_type.to_s] || []
    rules.each do |rule|
      return rule["action"] if match_rule?(rule["conditions"], attributes)
    end
    nil
  end

  private

  def self.match_rule?(conditions, attributes)
    conditions.all? do |key, expected|
      actual = attributes[key.to_sym] || attributes[key]
      case key.to_s
      when "buyer_country", "service_location"
        case expected
        when "EU"
          TaxConfig.eu_countries.include?(actual)
        when "not_EU"
          !TaxConfig.eu_countries.include?(actual)
        else
          actual == expected
        end
      else
        actual.to_s == expected.to_s
      end
    end
  end
end
