#!/bin/bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] ||
{
    _:gmt_warn_n '[KVSH]' ' you can not use it without sourcing [> source kvsh.gig]'
    exit 1
}
