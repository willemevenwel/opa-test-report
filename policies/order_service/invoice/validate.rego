package order_service.invoice

default valid = false

valid if input.total >= 0
