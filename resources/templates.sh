#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] ||
{
    _:gmt_warn_n '[KVSH]' ' you can not use it without sourcing [> source it.sh]'
    exit 1
}

M_METADATA_CONTENT='
labels:
  version: $(M_VERSION)
  name: AWS Basic Infrastructure
  short: $(M_MODULE_SHORT)
  kind: infrastructure
  provider: aws
  provides-vms: true
  provides-pubips: $(M_PUBLIC_IPS)
'

M_CONFIG_CONTENT='
kind: $(M_MODULE_SHORT)-config
$(M_MODULE_SHORT):
  name: $(M_NAME)
  instance_count: $(M_VMS_COUNT)
  region: $(M_REGION)
  use_public_ip: $(M_PUBLIC_IPS)
  force_nat_gateway: $(M_NAT_GATEWAY)
  rsa_pub_path: "$(M_SHARED)/$(M_VMS_RSA).pub"
  os: $(M_OS)
'

M_STATE_INITIAL='
kind: state
$(M_MODULE_SHORT):
  status: initialized
'