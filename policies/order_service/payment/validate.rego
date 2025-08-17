package order_service.payment

default valid = false

valid if input.amount > 0
