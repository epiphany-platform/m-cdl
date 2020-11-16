#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] ||
{
    _:gmt_warn_n '[KVSH]' ' you can not use it without sourcing [> source it.sh]'
    exit 1
}

M_MODULE_SHORT="cdldp"
M_CONFIG_NAME="awsbi-config.yml"
M_STATE_FILE_NAME="state.yml"
