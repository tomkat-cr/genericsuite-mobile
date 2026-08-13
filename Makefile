.PHONY: help
SHELL := /bin/bash

help:
	cat Makefile

lint:
	flutter analyze
	flutter format --set-exit-if-changed .

test:
	cd genericsuite_flutter && flutter test --coverage --coverage-path coverage/lcov.info && cd -

sast-test:
	snyk auth
	snyk code test --severity-threshold=high --all-projects .
	snyk test --severity-threshold=high --all-projects .
