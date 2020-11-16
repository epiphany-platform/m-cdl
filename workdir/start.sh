#!/bin/bash
# set -x 

ProgName=$(basename $0)

sub_help(){
    echo "Usage: $ProgName <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    init"
    echo "    plan"
    echo "    apply"
    echo "    audit"
    echo "    destroy"
    echo "    all"
    echo ""
    echo "For help with each subcommand run:"
    echo "$ProgName <subcommand> -h|--help"
    echo ""
}


function _:gcdbrown() 
{ echo -en "\e[0;33m$@"; }

function _:gcreset_n()
{ echo -e "\e[0m$@"; }

function _:gc_warn()
{
    _:gcdbrown "[GINGER][WARN] "
    _:gcreset_n "$@"
}

# source $(M_RESOURCES)/templates.sh
# source $(M_RESOURCES)/consts.sh
# source $(M_RESOURCES)/defaults.sh
# source $(M_RESOURCES)/*.sh

function metadata()
{
    echo metadata
    #	@echo "$$M_METADATA_CONTENT"	
}


function init()
{
    echo init
    mkdir -p /shared/cdl
    cp /shared/build/azepi/inventory /shared/cdl/inventory
    cp /shared/build/azepi/kubeconfig /shared/cdl/kubeconfig
    #cp /srv/helm/values.yaml /shared/cdl/cdl-config.yaml
}

function plan() 
{
    echo plan
}

function apply() {
    echo apply
    ansible-playbook /srv/ansible/cdldeployment.yml -i /shared/build/azepi/inventory --key-file "/shared/vms_rsa"
}

function audit() {
    echo audit
}

function destroy() {
    echo destroy
}

function all() {
    pwd
    init
    plan
    apply
    audit
    destroy
}

subcommand=${1:-"all"} #all
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        echo "> $subcommand"
        shift
        $subcommand $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "Run '$ProgName --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac

# setup: $(M_SHARED)/$(M_MODULE_SHORT)
# 	#AWSBI | setup | Ensure required directories exist

# ensure-state-file: $(M_SHARED)/$(M_STATE_FILE_NAME)
# 	#AWSBI | ensure-state-file | Checks if 'state' file exists

# template-config-file:
# 	#AWSBI | template-config-file | will template config file (and backup previous if exists)
# 	@if test -f $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME); then mv $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME) $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME).backup ; fi
# 	@echo "$$M_CONFIG_CONTENT" > $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME)

# initialize-state-file:
# 	#AWSBI | initialize-state-file | will initialize state file
# 	@echo "$$M_STATE_INITIAL" > $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-state.tmp
# 	@yq m -i -x $(M_SHARED)/$(M_STATE_FILE_NAME) $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-state.tmp
# 	@rm $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-state.tmp

# #TODO: Get rid of error: '[Makefile:170: module-plan] Error 1 (ignored)'
# module-plan:
# 	#AWSBI | module-plan | will perform module plan
# 	@yq m -x $(M_SHARED)/$(M_STATE_FILE_NAME) $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME) > $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-future-state.tmp
# 	@yq w -i $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-future-state.tmp kind state
# 	@- yq compare $(M_SHARED)/$(M_STATE_FILE_NAME) $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-future-state.tmp
# 	@rm $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-future-state.tmp

# display-config-file:
# 	#AWSBI | display-config-file | config file content is:
# 	@cat $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME)

# update-state-after-apply:
# 	#AWSBI | update-state-after-apply | will update state file after apply
# 	@cp $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME) $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-config.tmp.yml
# 	@yq d -i $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-config.tmp.yml kind
# 	@yq m -x -i $(M_SHARED)/$(M_STATE_FILE_NAME) $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-config.tmp.yml
# 	@yq w -i $(M_SHARED)/$(M_STATE_FILE_NAME) $(M_MODULE_SHORT).status applied
# 	@rm $(M_SHARED)/$(M_MODULE_SHORT)/AWSBI-config.tmp.yml

# update-state-after-destroy:
# 	#AWSBI | update-state-after-destroy | will clean state file after destroy
# 	@yq d -i $(M_SHARED)/$(M_STATE_FILE_NAME) '$(M_MODULE_SHORT)'
# 	@yq w -i $(M_SHARED)/$(M_STATE_FILE_NAME) $(M_MODULE_SHORT).status destroyed

# #TODO check if there is state file
# #TODO check if there is config
# assert-init-completed:
# 	#AWSBI | assert-init-completed | will check if all initialization steps are completed

# #TODO validate if config is correct
# #TODO consider https://github.com/santhosh-tekuri/jsonschema as it's small
# validate-config:
# 	#AWSBI | validate-config | will perform config validation

# #TODO validate if state file is correct
# #TODO consider https://github.com/santhosh-tekuri/jsonschema as it's small
# validate-state:
# 	#AWSBI | validate-state | will perform state file validation

# template-tfvars:
# 	#AWSBI | template-tfvars | will template .tfvars.json file
# 	@yq read -jP $(M_SHARED)/$(M_MODULE_SHORT)/$(M_CONFIG_NAME) '$(M_MODULE_SHORT)*' > $(M_RESOURCES)/terraform/vars.tfvars.json


# guard-%:
# 	@if [ "${${*}}" = "" ]; then \
# 		echo "Environment variable $* not set"; \
# 		exit 1; \
# 	fi

# $(M_SHARED)/$(M_STATE_FILE_NAME):
# 	@mkdir -p $(dir $@)
# 	@touch $@

# $(M_SHARED)/$(M_MODULE_SHORT):
# 	@mkdir -p $@
