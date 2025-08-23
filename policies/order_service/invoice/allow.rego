package order_service.invoice

import rego.v1

default allow = false

allow if input.status == "open"
