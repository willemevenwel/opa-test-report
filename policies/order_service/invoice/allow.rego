package order_service.invoice

default allow = false

allow if input.status == "open"
