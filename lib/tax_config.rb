module TaxConfig
  CONFIG = YAML.load_file(File.join(__dir__, "..", "config", "tax_config.yml")).freeze

  def self.eu_countries
    CONFIG["eu_countries"]
  end

  def self.spanish_vat
    CONFIG["spanish_vat"]
  end

  def self.local_vat_rates
    CONFIG["local_vat_rates"]
  end

  def self.local_vat_for(country)
    normalized_country = country.to_s.split.map(&:capitalize).join(" ")
    local_vat_rates[normalized_country] || spanish_vat
  end
end
