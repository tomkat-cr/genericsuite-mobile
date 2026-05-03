.PHONY: help
SHELL := /bin/bash

help:
	cat Makefile

sast-test:
	snyk code test --severity-threshold=high --all-projects .
	snyk test --severity-threshold=high --all-projects .
