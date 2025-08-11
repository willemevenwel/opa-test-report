package policyone

default allow = false

allow if {
    input.role == "admin"
}

allow if {
    input.user == "alice"
}
