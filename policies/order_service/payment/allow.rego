package order_service.payment

default allow = false

allow if input.method == "credit_card"
