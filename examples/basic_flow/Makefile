ROOT_DIR := /tmp
#ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

M_NAME ?= wpo-rs-2

AZBI := epiphanyplatform/azbi:latest
AZKS := epiphanyplatform/azks:latest
AZEPI := epiphanyplatform/azepi:latest
CDL := epiphanyplatform/cdldp:latest

VMS_RSA_FILENAME := vms_rsa

define RUN_AZBI
docker run --rm \
	-v $(ROOT_DIR)/shared/:/shared/ \
	-t $(AZBI) \
	$(1) \
	M_ARM_CLIENT_ID=$$ARM_CLIENT_ID \
	M_ARM_CLIENT_SECRET=$$ARM_CLIENT_SECRET \
	M_ARM_SUBSCRIPTION_ID=$$ARM_SUBSCRIPTION_ID \
	M_ARM_TENANT_ID=$$ARM_TENANT_ID
endef

define RUN_AZKS
docker run --rm \
	-v $(ROOT_DIR)/shared/:/shared/ \
	-t $(AZKS) \
	$(1) \
	M_ARM_CLIENT_ID=$$ARM_CLIENT_ID \
	M_ARM_CLIENT_SECRET=$$ARM_CLIENT_SECRET \
	M_ARM_SUBSCRIPTION_ID=$$ARM_SUBSCRIPTION_ID \
	M_ARM_TENANT_ID=$$ARM_TENANT_ID
endef

define RUN_AZEPI
docker run --rm \
	-v $(ROOT_DIR)/shared/:/shared/ \
	-t $(AZEPI) \
	$(1)
endef

define RUN_CDL
docker run --rm \
	-v $(ROOT_DIR)/shared/:/shared/ \
	-t $(CDL) \
	$(1)
endef


-include ./azure.mk

export

.PHONY: all destroy clean prepare-azepi finish-azepi

all: prepare-azepi finish-azepi

destroy: plan-destroy-azks destroy-azks plan-destroy-azbi destroy-azbi

prepare-azepi: init-azbi plan-azbi apply-azbi \
	init-azks plan-azks apply-azks init-azepi

finish-azepi: plan-azepi apply-azepi

clean:
	@rm -rf $(ROOT_DIR)/shared/

.PHONY: init-azbi plan-azbi apply-azbi output-azbi plan-destroy-azbi destroy-azbi

init-azbi: setup
	@$(call RUN_AZBI,init) \
		M_NAME=$(M_NAME) \
		M_VMS_COUNT=4 \
		M_PUBLIC_IPS=true

plan-azbi: setup
	@$(call RUN_AZBI,plan)

apply-azbi: setup
	@$(call RUN_AZBI,apply)

output-azbi: setup
	@$(call RUN_AZBI,output)

plan-destroy-azbi: setup
	@$(call RUN_AZBI,plan-destroy)

destroy-azbi: setup
	@$(call RUN_AZBI,destroy)

.PHONY: init-azks plan-azks apply-azks output-azks plan-destroy-azks destroy-azks

init-azks: setup
	@$(call RUN_AZKS,init) \
		M_NAME=$(M_NAME)

plan-azks: setup
	@$(call RUN_AZKS,plan)

apply-azks: setup
	@$(call RUN_AZKS,apply)

output-azks: setup
	@$(call RUN_AZKS,output)

plan-destroy-azks: setup
	@$(call RUN_AZKS,plan-destroy)

destroy-azks: setup
	@$(call RUN_AZKS,destroy)

.PHONY: init-azepi plan-azepi apply-azepi

init-azepi: setup
	@$(call RUN_AZEPI,init) \
		VMS_RSA_FILENAME=$(VMS_RSA_FILENAME)

plan-azepi: setup
	@$(call RUN_AZEPI,plan)

apply-azepi: setup
	@$(call RUN_AZEPI,apply)

.PHONY: init-cdldp plan-cdldp apply-cdldp destroy-cdldp

init-cdldp: setup
	@$(call RUN_CDL,init) \
		VMS_RSA_FILENAME=$(VMS_RSA_FILENAME)

plan-cdldp: setup
	@$(call RUN_CDL,plan)

apply-cdldp: setup
	@$(call RUN_CDL,apply)

destroy-cdldp: setup
	@$(call RUN_CDL,destroy)

.PHONY: setup

setup: $(ROOT_DIR)/shared/$(VMS_RSA_FILENAME)

$(ROOT_DIR)/shared/$(VMS_RSA_FILENAME):
	@mkdir -p $(dir $@)
	@ssh-keygen -t rsa -b 4096 -f $@ -N '' 2>&1 >/dev/null
