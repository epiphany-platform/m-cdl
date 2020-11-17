#!/bin/bash


# required parameters:
# ${1} inventory file
# ${2} ssh priv key

if [[ ! -z ${DEBUG} ]]
then
    set -x
fi

function _:gcdbrown()
{ echo -en "\e[0;33m$@"; }

function _:gcreset_n()
{ echo -e "\e[0m$@"; }

function _:gc_warn() {
    _:gcdbrown "[CDLDEPLOY][WARN] " >&2
    _:gcreset_n "$@" >&2
}

function _:gc_info() {
    _:gcdbrown "[CDLDEPLOY][INFO] " >&2
    _:gcreset_n "$@"  >&2
}
# [todo]: fix the rest of the colors
function _:gc_error() {
    _:gcdbrown "[CDLDEPLOY][ERROR] "  >&2
    _:gcreset_n "$@"  >&2
}

function _:precheck() {
    if [[ -z ${1} ]] || [[ ! -f ${1} ]] ; then
       _:gc_error "no inventory file provided"
       return -1
    fi

    if [[ -z ${2} ]] || [[ ! -f ${2} ]] ; then
       _:gc_error "[ERROR][CDL_DEPLOY]  no private key specified"
       return -2
    elif ! file ${2} | grep "private key" > /dev/null ; then
       _:gc_error "private key does not looks like usable private key"
       return -3
    fi
    _:gc_info "precheck ok"
}

function _:preapply() {
    # check if there is anything that need to be filled to values.yml
    # todo this whole section
    if [[ -z ${1} ]] || [[ ! -f ${1} ]] ; then
       _:gc_error "no inventory file provided"
       return -1
    fi

    if [[ -z ${2} ]] || [[ ! -f ${2} ]] ; then
       _:gc_error "[ERROR][CDL_DEPLOY]  no private key specified"
       return -2
    elif ! file ${2} | grep "private key" > /dev/null ; then
       _:gc_error "private key does not looks like usable private key"
       return -3
    fi
    _:gc_info "precheck ok"
}

function _:init_config() {
    # [todo]: move those away from here?
    local INVENTORY_FILE="/shared/cdl/inventory"
    local CDL_DELPLOY_CFG="/shared/cdl/config"

    BTR_PG_IP="$(grep -P1 '\[postgresql\]' ${INVENTORY_FILE} | grep -oP 'ansible_host=\K([0-9\.]*)')"
    BTR_RMQ_IP="$(grep -P1 '\[postgresql\]' ${INVENTORY_FILE} | grep -oP 'ansible_host=\K([0-9\.]*)')"

    # for user inspection
    echo "${BTR_RMQ_IP}" >> CDL_DELPLOY_CFG
    echo "${BTR_PG_IP}" >> CDL_DELPLOY_CFG

    # [todo]: kafka is not requred right now, fix it later
    # AC_KAFKA="$(grep -P1 '\[postgresql\]' ${INVENTORY_FILE} | grep -oP 'ansible_host=\K([0-9\.]*)')"
    #echo AC_KAFKA=${AC_KAFKA} >> CDLDEPLOY.cfg

    if [[ -z ${BTR_PG_IP} ]] ; then
        echo "failed to determine postgresql instance"
        return -4
    fi

    if [[ -z ${BTR_RMQ_IP} ]] ; then
        echo "failed to find message query server"
        return -5
    fi

    source "/shared/cdl/config"

    local missing=0
    if [[ -z ${BTR_PG_USER} ]] ;        then _:gc_error could not find BTR_PG_USER in config        ;fi
    if [[ -z ${BTR_PG_PASSWORD} ]] ;    then _:gc_error could not find BTR_PG_PASSWORD in config    ;fi
    if [[ -z ${BTR_PG_IP} ]] ;          then _:gc_error could not find BTR_PG_IP in config          ;fi
    if [[ -z ${BTR_PG_DBNAME} ]] ;      then _:gc_error could not find BTR_PG_DBNAME in config      ;fi
    if [[ -z ${BTR_RMQ_USER} ]] ;       then _:gc_error could not find BTR_RMQ_USER in config       ;fi
    if [[ -z ${BTR_RMQ_PASSWORD} ]] ;   then _:gc_error could not find BTR_RMQ_PASSWORD in config   ;fi
    if [[ -z ${BTR_RMQ_IP} ]] ;         then _:gc_error could not find BTR_RMQ_IP in config         ;fi
    if [[ -z ${BTR_RMQ_PORT} ]] ;       then _:gc_error could not find BTR_RMQ_PORT in config       ;fi
    if [[ ${missing} -ne 0 ]] ; then return -19 ;fi

    sed -i /shared/cdl/values -e 's/{BTR_PG_USER}/${BTR_PG_USER}/g'
    sed -i /shared/cdl/values -e 's/{BTR_PG_PASSWORD}/${BTR_PG_PASSWORD}/g'
    sed -i /shared/cdl/values -e 's/{BTR_PG_IP}/${BTR_PG_IP}/g'
    sed -i /shared/cdl/values -e 's/{BTR_PG_DBNAME}/${BTR_PG_DBNAME}/g'
    sed -i /shared/cdl/values -e 's/{BTR_RMQ_USER}/${BTR_RMQ_USER}/g'
    sed -i /shared/cdl/values -e 's/{BTR_RMQ_PASSWORD}/${BTR_RMQ_PASSWORD}/g'
    sed -i /shared/cdl/values -e 's/{BTR_RMQ_IP}/${BTR_RMQ_IP}/g'
    sed -i /shared/cdl/values -e 's/{BTR_RMQ_PORT}/${BTR_RMQ_PORT}/g'
    if grep -oP '{BTR_[_A-Za-z0-9]+}' /shared/cdl/values
    then
        _:gc_error "it seems that configuration can not be properly defined, bailing out"
        return -20
    fi
    # [todo]: copy shared/cdl/values wherever you need it
    return 0
}


function sub_help() {
    # there may be erro here, ${0} may not work as requested
    # [todo]: help for each subcommand?
    cat << EOF
 :========================================:
 Usage: ${0} <subcommand> [options]
 Subcommands:
     init
     plan
     apply
     audit
     destroy
     all

 For help with each subcommand run:
 ${0} <subcommand> -h|--help
 :========================================:
EOF
}

function metadata() {
    echo metadata
    #	@echo "$$M_METADATA_CONTENT"
}


function init() {
    _:gc_info "running init:"
    mkdir -p /shared/cdl
    if ! _:precheck ; then
        _:gc_error "precheck failed!"
        return -11
    fi

    cp /shared/build/azepi/inventory /shared/cdl/inventory
    cp /shared/build/azepi/kubeconfig /shared/cdl/kubeconfig
    cp /srv/resources/config /shared/cdl/config
    #cp /srv/helm/values.yaml /shared/cdl/cdl-config.yaml
}

function plan() {
    _:gc_info "running: plan"
}

function apply() {
    _:gc_info "running: apply"
    ansible-playbook /srv/ansible/cdldeployment.yml -i /shared/cdl/inventory --key-file "/shared/vms_rsa"
}

function audit() {
    _:gc_info "running: audit"
}

function destroy() {
    _:gc_info "running: destroy"
}

function all() {
    pwd
    init
    # plan
    apply
    # audit
    destroy
}

__cdl_progname="${0}"
subcommand=${1:-"all"} #all
case "${subcommand}" in
    "" | "-h" | "--help")
        sub_help ${__cdl_progname}
        ;;
    *)
        _:gc_info "> ${subcommand}"
        shift
        ${subcommand} ${@}
        # not equal 0 instead of equal 127?
        if [[ "${?}" -eq 127 ]]; then
            _:gc_error "${subcommand} is not a known command."
            _:gc_error "Run ${__cdl_progname} --help for a list of known subcommands."
            exit 1
        fi
        ;;
esac
