# Policy for validating payment in the order service
package order_service.payment

# Import the latest Rego standard library
import rego.v1

# By default, a payment is not valid
default valid = false

# A payment is valid if the input amount is greater than 0
valid if input.amount > 0
