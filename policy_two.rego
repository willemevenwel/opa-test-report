package policytwo

default access = false

access if {
    input.group == "engineering"
}

access if {
    input.user == "bob"
}
