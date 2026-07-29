SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
# =================================================
INFO_COLOR := \033[36;1m
WARNING_COLOR := \033[33;1m
ERROR_COLOR := \033[31;1m
RESET_COLOR := \033[0m
# ================================================
ENV ?= dev
MAKEFLAGS += --warn-undefined-variables --no-print-directory
TF_DIR = terraform
TF_CHG_DIR = terraform -chdir=$(TF_DIR)
# ================================================

.PHONY: help tf.init tf.normalize tf.pipe tf.apply
.DEFAULT_GOAL := help

.SILENT:

help: ## shows this help
	@grep -E "^[a-zA-Z0-9_.-]+:.*?## .*$$" $(MAKEFILE_LIST) | \
	sort | awk 'BEGIN {FS = ":.*?## "} {printf "$(INFO_COLOR)%-20s$(RESET_COLOR)%s\n", $$1, $$2}'

tf.init: ## initializes terraform
	$(TF_CHG_DIR) init
	echo "✅ Initializing Done"

tf.normalize: ## formats and lints terraform files
	$(TF_CHG_DIR) fmt
	tflint --chdir=$(TF_DIR)

tf.pipe: tf.normalize ## validates, plans and scans terraform config
	$(TF_CHG_DIR) validate
	$(TF_CHG_DIR) plan --out $(TF_DIR)/tfplan
	$(TF_CHG_DIR) show -json $(TF_DIR)/tfplan > $(TF_DIR)/tfplan.json
	trivy config $(TF_DIR)/tfplan.json
	echo "✅ Piping Done"

tf.apply: tf.pipe ## applies the terraform plan
	$(TF_CHG_DIR) apply --auto-approve
	echo "✅ Apply Done"
