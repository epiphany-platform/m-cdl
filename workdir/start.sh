#!/bin/bash

PRIV_KEY="/shared/vms_rsa"

SOURCE_INVENTORY="/shared/build/azepi/inventory"
SOURCE_KUBECONFIG="/shared/build/azepi/kubeconfig"
SOURCE_CDL_CFG="/srv/resources/config.yml"

DEST_INVENTORY="/shared/cdl/inventory"
DEST_KUBECONFIG="/shared/cdl/kubeconfig"
DEST_CDL_CFG="/shared/cdl/config.yml"

if [[ -n ${DEBUG} ]]
then
    set -x
fi

function _:gcdbrown()
{ echo -en "\e[0;33m" "${@}"; }

function _:gcreset_n()
{ echo -e "\e[0m" "${@}"; }

function _:gc_warn() {
    _:gcdbrown "[CDLDEPLOY][WARN] " >&2
    _:gcreset_n "${@}" >&2
}

function _:gc_info() {
    _:gcdbrown "[CDLDEPLOY][INFO] " >&2
    _:gcreset_n "${@}"  >&2
}
# [todo]: fix the rest of the colors
function _:gc_error() {
    _:gcdbrown "[CDLDEPLOY][ERROR] "  >&2
    _:gcreset_n "${@}"  >&2
}

function _:precheck() {
    if [[ -z ${SOURCE_INVENTORY} ]] || [[ ! -f ${SOURCE_INVENTORY} ]] ; then
       _:gc_error "no inventory file provided"
       return 1
    fi

    if [[ -z ${PRIV_KEY} ]] || [[ ! -f ${PRIV_KEY} ]] ; then
       _:gc_error "[ERROR][CDL_DEPLOY]  no private key specified"
       return 2
    elif ! file "${PRIV_KEY}" | grep "private key" > /dev/null ; then
       _:gc_error "private key does not looks like usable private key"
       return 3
    fi

    if [[ -z ${SOURCE_KUBECONFIG} ]] || [[ ! -f ${SOURCE_KUBECONFIG} ]] ; then
        _:gc_error "no kubeconfig file provided"
        return 4
    fi

    _:gc_info "precheck ok"
}

function _:preapply() {
    # [todo]
    _:gc_info "preapply ok"
}

function init() {
    _:gc_info "running init:"
    mkdir -p /shared/cdl
    if ! _:precheck ; then
        _:gc_error "precheck failed!"
        return 1
    fi

    cp "${SOURCE_INVENTORY}" "${DEST_INVENTORY}"
    cp "${SOURCE_KUBECONFIG}" "${DEST_KUBECONFIG}"
    cp "${SOURCE_CDL_CFG}" "${DEST_CDL_CFG}"

    #_:init_config
}

function plan() {
    _:gc_info "running: plan"
}

function apply() {
    _:gc_info "running: apply"
    ansible-playbook /srv/ansible/cdldeployment.yml \
        -i "${DEST_INVENTORY}" \
        --key-file "${PRIV_KEY}" \
        -e "@${DEST_CDL_CFG}" \
        -e "state=present"
}

function audit() {
    _:gc_info "running: audit"
}

function destroy() {
    _:gc_info "running: destroy"
    ansible-playbook /srv/ansible/cdldeployment.yml \
        -i "${DEST_INVENTORY}" \
        --key-file "${PRIV_KEY}" \
        -e "@${DEST_CDL_CFG}" \
        -e "state=absent"
}

function all() {
    pwd
    init
    # plan
    apply
    # audit
    destroy
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



__cdl_progname="${0}"
subcommand=${1:-"all"} #all
case "${subcommand}" in
    "" | "-h" | "--help")
        sub_help "${__cdl_progname}"
        ;;
    *)
        _:gc_info "> ${subcommand}"
        shift
        ${subcommand} "${@}"
        # not equal 0 instead of equal 127?
        if [[ "${?}" -eq 127 ]]; then
            _:gc_error "${subcommand} is not a known command."
            _:gc_error "Run ${__cdl_progname} --help for a list of known subcommands."
            exit 1
        fi
        ;;
esac
