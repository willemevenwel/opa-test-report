# Makefile for OPA policy tests (minimal, robust, correct escaping)
POLICY_PATHS := $(shell find policies -type d -mindepth 2)
ENTITY_TARGETS := $(patsubst policies/%,%,$(POLICY_PATHS))
SERVICE_TARGETS := $(sort $(foreach e,$(ENTITY_TARGETS),$(firstword $(subst /, ,$e))))

.PHONY: test test-verbose coverage list-tests

test:
	./opa test policies tests test_data

test-verbose:
	./opa test -v policies tests test_data

coverage:
	./opa test --coverage --format=json policies tests test_data > coverage.json

# Per-entity test and coverage targets
$(foreach entity,$(ENTITY_TARGETS),\
  $(eval test-$(entity): ; @echo ">>> Running tests for $(entity)..." ; ./opa test policies/$(entity) tests/$(entity) test_data) \
  $(eval test-$(entity)-verbose: ; @echo ">>> Running verbose tests for $(entity)..." ; ./opa test -v policies/$(entity) tests/$(entity) test_data) \
		$(eval coverage-$(entity): ; @echo ">>> Running coverage for $(entity)..." ; ./opa test --coverage --format=json policies/$(entity) tests/$(entity) test_data > coverage.json) \
)

# Per-service test and coverage targets
$(foreach service,$(SERVICE_TARGETS),\
  $(eval test-$(service): ; @echo ">>> Running tests for service $(service)..." ; ./opa test policies/$(service) tests/$(service) test_data) \
  $(eval test-$(service)-verbose: ; @echo ">>> Running verbose tests for service $(service)..." ; ./opa test -v policies/$(service) tests/$(service) test_data) \
		$(eval coverage-$(service): ; @echo ">>> Running coverage for service $(service)..." ; ./opa test --coverage --format=json policies/$(service) tests/$(service) test_data > coverage.json) \
)

list-tests:
	@echo "Available entity test targets:"; \
	for t in $(ENTITY_TARGETS); do \
		echo "  make test-$$t"; \
		echo "  make test-$$t-verbose"; \
		echo "  make coverage-$$t"; \
	done; \
	echo ""; \
	echo "Available service-level targets:"; \
	for s in $(SERVICE_TARGETS); do \
		echo "  make test-$$s"; \
		echo "  make test-$$s-verbose"; \
		echo "  make coverage-$$s"; \
	done; \
	echo ""; \
	echo "All tests:"; \
	echo "  make test"; \
	echo "  make test-verbose"; \
	echo "  make coverage"
