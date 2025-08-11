package policytwo

test_access_engineering if {
    test_input := {"group": "engineering"}
    access with input as test_input
}

test_access_bob if {
    test_input := {"user": "bob"}
    access with input as test_input
}

test_deny_charlie if {
    test_input := {"user": "charlie"}
    not access with input as test_input
}
