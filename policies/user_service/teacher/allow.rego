package user_service.teacher

default allow = false

allow if input.role == "teacher"
