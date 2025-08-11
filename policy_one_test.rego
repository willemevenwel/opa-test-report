package policyone

test_allow_admin if {
    test_input := {"role": "admin"}
    allow with input as test_input
}

test_allow_alice if {
    test_input := {"user": "alice"}
    allow with input as test_input
}

test_deny_bob if {
    test_input := {"user": "bob"}
    not allow with input as test_input
}
