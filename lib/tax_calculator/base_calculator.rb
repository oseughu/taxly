module TaxCalculator
  EU_COUNTRIES = [
    "Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic",
    "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary",
    "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta",
    "Netherlands", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia",
    "Spain", "Sweden"
  ].freeze

  VAT_SPANISH = 0.21

  class BaseCalculator
    attr_reader :price, :buyer_country, :buyer_type, :service_location

    def initialize(price:, buyer_country:, buyer_type:, service_location: nil)
      @price = price
      @buyer_country = buyer_country
      @buyer_type = buyer_type
      @service_location = service_location
    end

    def in_eu?(country)
      EU_COUNTRIES.include?(country)
    end

    def local_vat_for(country)
      vat_rates = {
        "France"  => 0.20,
        "Germany" => 0.19,
        "Italy"   => 0.22,
        "Spain"   => VAT_SPANISH
      }
      vat_rates[country] || VAT_SPANISH
    end
  end
end
