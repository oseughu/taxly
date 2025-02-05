# Taxly

Taxly is a robust tax calculation API that automates the computation of VAT and other tax-related amounts for a variety of transactions. It is designed to support the sale of physical goods, digital services, and onsite services, making it simple to comply with tax regulations across different countries. This was built using Ruby on Rails.

## Features

- **Multi-transaction Support:** Calculate taxes for:
  - Physical products
  - Digital services (e.g. digital subscriptions)
  - Onsite services (e.g. in-person training courses)
- **EU & Local VAT Handling:** Automatically apply Spanish VAT for transactions within Spain and local VAT rates for buyers in other EU countries.
- **Reverse Charge & Export Logic:** Automatically manage reverse charges for companies and mark exports when selling to buyers outside the EU.
- **Clean, Modular Code:** Uses Ruby’s `case` statements for clearer logic flow.
- **RESTful API:** Exposes endpoints for easy integration with front-end systems or third-party applications.

## Installation

1. **Clone the repository:**

```bash
git clone https://github.com/oseughu/taxly.git
cd taxly

```

2. **Install dependencies:**
   Ensure you have Ruby and Bundler installed, then run:

```bash
bundle install
```

3. Run the server:

```bash
rails server
```

Your application will be running at <http://localhost:3000>.

## API Endpoints

POST /calculate

The /calculate endpoint accepts a JSON payload containing transaction details and returns a tax calculation result based on the provided parameters.

Request Payload

- product_type (string, required):
  The type of product or service. Valid values are:
- "good" — for physical products.
- "digital" — for digital subscription services.
- "onsite" — for in-person training courses or onsite services.
- price (number, required):
  The sale price of the product or service.
- buyer_country (string, required):
  The country where the buyer is located (e.g. "Spain", "France").
- buyer_type (string, required):
  The type of buyer. Valid values are "individual" or "company".
- service_location (string, conditionally required):
  For "onsite" transactions only; the country where the service is provided.

## Example Requests

- Physical Goods:

```json
{
  "product_type": "good",
  "price": 100.0,
  "buyer_country": "France",
  "buyer_type": "individual"
}
```

- Digital Services:

```json
{
  "product_type": "digital",
  "price": 100.0,
  "buyer_country": "Spain",
  "buyer_type": "company"
}
```

- Onsite Services:

```json
{
  "product_type": "onsite",
  "price": 200.0,
  "buyer_country": "USA",
  "buyer_type": "individual",
  "service_location": "Germany"
}
```

## Example Responses

On success, the endpoint returns a JSON object with:

- transaction_type (string):
  The type of transaction, such as:
- "good" — for standard physical product transactions.
- "service/digital" — for digital services.
- "service/onsite" — for onsite services.
- "reverse charge" — if no VAT is applied (typically for companies in the EU).
- "export" — for transactions outside the EU.
- tax_rate (number):
  The VAT rate that was applied (e.g. 0.21 for Spanish VAT).
- tax_amount (number):
  The calculated tax amount based on the price and VAT rate.

### Example Successful Response

```json
{
  "transaction_type": "good",
  "tax_rate": 0.2,
  "tax_amount": 20.0
}
```

### Error Responses

- 400 Bad Request:
  Returned when required parameters are missing.

```json
{ "error": "Missing required parameters" }
```

- 422 Unprocessable Entity:

Returned when an invalid product type is provided or required parameters (such as service location for onsite transactions) are missing.

```json
{ "error": "Invalid product type: invalid_value" }
```

- 500 Internal Server Error:

Returned if an unexpected error occurs.

```json
{ "error": "An unexpected error occurred: <error_message>" }
```

## Testing

Taxly uses RSpec for testing the tax calculation logic. To run the test suite, execute:

```bash
bundle exec rspec
```

This will run all tests located in the spec/ directory and provide you with a report on the test coverage and outcomes.

## Extending the Application

To make the system adaptable and easily configurable, tax calculations are configured in the config/tax_config.yml file

Make changes to the file to see how calculations can be affected.

The tax calculation logic is split into separate classes under lib/tax_calculator/:
• BaseCalculator: Contains shared constants and helper methods.
• GoodsCalculator, DigitalServicesCalculator, OnsiteServicesCalculator: Each handles the tax logic for a specific transaction type.

This modular design makes it easy to:
• Update or add new tax rules.
• Integrate with external tax rate APIs.
• Extend functionality to support additional countries or services.
