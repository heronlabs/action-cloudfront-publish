.PHONY: test lint

test:
	bats tests/

lint:
	shellcheck core/*.sh
