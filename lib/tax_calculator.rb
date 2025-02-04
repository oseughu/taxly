require_relative "tax_calculator/base_calculator"
require_relative "tax_calculator/goods_calculator"
require_relative "tax_calculator/digital_services_calculator"
require_relative "tax_calculator/onsite_services_calculator"

module TaxCalculator
  def self.calculate(product_type:, price:, buyer_country:, buyer_type:, service_location: nil)
    case product_type
    when :good
      calculator = GoodsCalculator.new(price: price, buyer_country: buyer_country, buyer_type: buyer_type)
    when :digital
      calculator = DigitalServicesCalculator.new(price: price, buyer_country: buyer_country, buyer_type: buyer_type)
    when :onsite
      raise ArgumentError, "service location is required for onsite services" unless service_location
      calculator = OnsiteServicesCalculator.new(price: price, buyer_country: buyer_country, buyer_type: buyer_type, service_location: service_location)
    else
      raise ArgumentError, "Invalid product type: #{product_type}"
    end

    calculator.calculate
  end
end
