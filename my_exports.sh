#!/bin/bash

#==================================================================================================
af_services()
{
    echo "sch-web-log-srv-mets-mng-fct-opt-pstp-flw"
}

#==================================================================================================
tmpfarr()
{
#    local arrstr=$(af_services)
#    readarray -td, svcs <<<"$arrstr-"; unset 'svcs[-1]'; declare -p svcs;
    local svcs
    IFS='-' read -r -a svcs <<< $(af_services)
    for svc in "${svcs[@]}"
    do
        echo $svc
    done
}
export -f tmpfarr

#==================================================================================================
svc_args()
{
    local starg
    if [[ "$1" = "st" ]]; then
        starg="start"
    elif [[ "$1" = "stp" ]]; then
        starg="stop"
    elif [[ "$1" = "rs" ]]; then
        starg="stop"
    elif [[ "$1" = "sts" ]]; then
        starg="status"
    elif [[ "$1" = "en" ]]; then
        starg="is-enabled"
    fi
    echo $starg
}

#==================================================================================================
svc()
{
    if [[ -z $1 ]]; then
        echo "First arg [st, stp, rs, sts] not given"
        return
    fi
    if [[ -z $2 ]]; then
        echo "Second arg service name not given"
        return
    fi
    local starg=$(svc_args $1)
    sudo systemctl $starg $2
}
export -f svc

