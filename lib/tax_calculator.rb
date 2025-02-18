require_relative "tax_calculator/base_calculator"
require_relative "tax_calculator/goods_calculator"
require_relative "tax_calculator/digital_services_calculator"
require_relative "tax_calculator/onsite_services_calculator"

module TaxCalculator
  CALCULATOR_CLASSES = {
    good: GoodsCalculator,
    digital: DigitalServicesCalculator,
    onsite: OnsiteServicesCalculator
  }.freeze

  def self.calculate(product_type:, price:, buyer_country:, buyer_type:, service_location: nil)
    normalized_product_type = product_type.to_s.downcase.to_sym
    normalized_buyer_type = buyer_type.to_s.downcase.to_sym
    normalized_service_location = service_location&.to_s

    calculator_class = CALCULATOR_CLASSES[normalized_product_type]
    raise ArgumentError, "Invalid product type: #{product_type}" unless calculator_class

    create_calculator(
      calculator_class:,
      price:,
      buyer_country:,
      buyer_type: normalized_buyer_type,
      service_location: normalized_service_location
    )
  end

  private

  def self.create_calculator(calculator_class:, price:, buyer_country:, buyer_type:, service_location:)
    if calculator_class == OnsiteServicesCalculator && service_location.nil?
      raise ArgumentError, "service location is required for onsite services"
    end

    calculator = calculator_class.new(
      price:,
      buyer_country:,
      buyer_type:,
      service_location:
    )

    calculator.calculate
  end
end
