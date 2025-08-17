package user_service.teacher

allow if input.role == "teacher"

valid if input.id != ""

test_allow_teacher_role if allow with input as {"role": "teacher"}

test_deny_non_teacher if not allow with input as {"role": "student"}

test_valid_id if valid with input as {"id": "t1"}

test_invalid_id if not valid with input as {"id": ""}
