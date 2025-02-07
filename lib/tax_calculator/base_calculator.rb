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
  end
end
