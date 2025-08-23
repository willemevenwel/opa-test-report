package order_service.payment

import rego.v1

default allow = false

allow if input.method == "credit_card"
