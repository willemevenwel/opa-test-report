package order_service.invoice

import rego.v1

default valid = false

valid if input.total >= 0
