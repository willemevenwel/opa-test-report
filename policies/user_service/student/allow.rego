package user_service.student

default allow = false

allow if input.role == "student"
