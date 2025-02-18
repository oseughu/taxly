require_relative "tax_config"

module TaxRules
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "tax_rules.yml"))

  # Returns the first matching rule's action for a given product type and attribute hash.
  def self.rule_for(product_type, attributes)
    rules = CONFIG[product_type.to_s] || []
    rules.each do |rule|
      return rule["action"] if match_rule?(rule["conditions"], attributes.transform_keys(&:to_sym))
    end
    nil
  end

  private

  def self.match_rule?(conditions, attributes)
    conditions.all? do |key, expected|
      actual = attributes[key.to_sym]
      if [ "buyer_country", "service_location" ].include?(key.to_s)
        match_country_or_location?(expected, actual)
      else
        actual.to_s == expected.to_s
      end
    end
  end

  def self.match_country_or_location?(expected, actual)
    case expected
    when "EU"
      TaxConfig.eu_countries.map(&:downcase).include?(actual.to_s.downcase)
    when "not_EU"
      !TaxConfig.eu_countries.map(&:downcase).include?(actual.to_s.downcase)
    else
      actual.to_s.downcase == expected.downcase
    end
  end
end
