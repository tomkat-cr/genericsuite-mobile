.PHONY: help
SHELL := /bin/bash

help:
	cat Makefile

lint:
	cd genericsuite_flutter && \
	flutter analyze && \
	dart format --set-exit-if-changed . && \
	cd -

test:
	cd genericsuite_flutter && \
	flutter test --coverage --coverage-path coverage/lcov.info && \
	cd -

sast-test:
	snyk auth $$SNYK_API_KEY
	snyk code test --severity-threshold=high --all-projects .
	snyk test --severity-threshold=high --all-projects .

upgrade:
	cd genericsuite_flutter && \
	flutter pub upgrade && \
	cd -

install:
	cd genericsuite_flutter && \
	flutter pub get && \
	cd -

pre-publish: upgrade install lint test
	cd genericsuite_flutter && \
	flutter pub publish --dry-run && \
	cd -

publish: upgrade install lint test
	cd genericsuite_flutter && \
	flutter pub publish && \
	cd -
