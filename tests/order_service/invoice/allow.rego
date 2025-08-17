package order_service.invoice

test_allow_open_status if allow with input as {"status": "open"}

test_deny_closed_status if not allow with input as {"status": "closed"}