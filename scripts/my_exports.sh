#!/bin/bash

MLPIPE_PATH=/home/vagrant/afprojects
MLPIPE_OS_PATH=/home/vagrant/afprojects

#==================================================================================================
nvkexp()
{
    if [[ -z $1 ]]; then
        echo "no arguments given"
    else
        echo "this is nikhil $1"
    fi
}
export -f nvkexp

#==================================================================================================
af_services()
{
    echo "sch-web-log-srv-wrk-flw"
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
af_services_from_short()
{
    local svcs
    IFS='-' read -r -a svcs <<< $(af_services)
    local svc=""
    local prfx=$(get_prefix)
    if [[ "$2" = "web" ]]; then
        svc=$prfx"webserver"
    elif [[ "$2" = "flw" ]]; then
        svc=$prfx"flower"
    elif [[ "$2" = "srv" ]]; then
        svc=$prfx"server"
    elif [[ "$2" = "wrk" ]]; then
        svc=$prfx"worker"
    elif [[ "$2" = "mets" ]]; then
        svc=$prfx"metrics"
    elif [[ "$2" = "sch" ]]; then
        svc=$prfx"scheduler"
    elif [[ "$2" = "log" ]]; then
        svc=$prfx"serve-logs"
    fi

    if [[ "$1" = "os" ]]; then
        svc=$svc"-os"
    fi
    echo $svc
}


#==================================================================================================
rsallt()
{
    if [[ "$1" = "az" ]]; then
        sudo $MLPIPE_PATH/scripts/start_services restart
    elif [[ "$1" = "os" ]]; then
        sudo $MLPIPE_OS_PATH/scripts/start_services restart
    fi
}
export -f rsallt


#==================================================================================================
stpallt()
{
    if [[ "$1" = "az" ]]; then
        sudo MLPIPE_PATH/scripts/stop_services 
    elif [[ "$1" = "os" ]]; then
        sudo MLPIPE_OS_PATH/scripts/stop_services
    fi
}
export -f stpallt


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

#==================================================================================================
get_prefix()
{
    echo "afgdx-"
}

#==================================================================================================
afhome()
{
    if [[ "$1" = "az" ]]; then
        export AIRFLOW_HOME=$MLPIPE_PATH/airflow
    elif [[ "$1" = "os" ]]; then
        export AIRFLOW_HOME=$MLPIPE_OS_PATH/airflow
    fi
    echo $AIRFLOW_HOME
}
export -f afhome


#==================================================================================================
svct()
{
    local svc=$(af_services_from_short $1 $2)
    local starg=$(svc_args $3)
    sudo systemctl $starg $svc
}


#==================================================================================================
strt()
{
    local svc=$(af_services_from_short $1 $2)
    local svc_path=""

    if [[ "$1" = "az" ]]; then
        svc_path=$MLPIPE_PATH
    elif [[ "$1" = "os" ]]; then
        svc_path=$MLPIPE_OS_PATH
    fi

    if [[ $(sudo systemctl is-enabled $svc) = "enabled" ]]; then
        echo "$svc already enabled"
        return
    fi
    sudo systemctl start $svc
    local stat=$(sudo systemctl is-active $svc)
    echo $svc $stat
}
export -f strt


#==================================================================================================
stp()
{
    local svc=$(af_services_from_short $1 $2)
    local svc_path=""

    if [[ "$1" = "az" ]]; then
        svc_path=$MLPIPE_PATH
    elif [[ "$1" = "os" ]]; then
        svc_path=$MLPIPE_OS_PATH
    fi

    if [[ $(sudo systemctl is-enabled $svc) = "enabled" ]]; then
        echo "$svc already enabled"
        return
    fi
    sudo systemctl stop $svc
    local stat=$(sudo systemctl is-active $svc)
    echo $svc $stat
}
export -f stp


#==================================================================================================
enblt()
{
    local svc=$(af_services_from_short $1 $2)
    local svc_path=""

    if [[ "$1" = "az" ]]; then
        svc_path=$MLPIPE_PATH
    elif [[ "$1" = "os" ]]; then
        svc_path=$MLPIPE_OS_PATH
    fi

    if [[ $(sudo systemctl is-enabled $svc) = "enabled" ]]; then
        echo "$svc already enabled"
        return
    fi
    sudo ln -s $svc_path/systemd/$svc.service /etc/systemd/system/$svc.service
    sudo systemctl enable $svc
    local stat=$(sudo systemctl is-enabled $svc)
    echo $svc $stat
}
export -f enblt


#==================================================================================================
dsblt()
{
    local svc=$(af_services_from_short $1 $2)
    local svc_path=""

    if [[ "$1" = "az" ]]; then
        svc_path=$MLPIPE_PATH
    elif [[ "$1" = "os" ]]; then
        svc_path=$MLPIPE_OS_PATH
    fi

    if [[ ! $(sudo systemctl is-enabled $svc) = "enabled" ]]; then
        echo "$svc already disabled"
        return
    fi

    if [[ $(sudo systemctl is-active $svc) = "active" ]]; then
        sudo systemctl stop $svc
    fi

    sudo systemctl disable $svc
    local stat=$(sudo systemctl is-enabled $svc)
    echo $svc $stat
}
export -f dsblt

#==================================================================================================
stall()
{
    local svcs
    IFS='-' read -r -a svcs <<< $(af_services)
    for svc in "${svcs[@]}"
    do
        strt $1 $svc
    done
}
export -f entall

#==================================================================================================
spall()
{
    local svcs
    IFS='-' read -r -a svcs <<< $(af_services)
    for svc in "${svcs[@]}"
    do
        stp $1 $svc
    done
}
export -f spall


#==================================================================================================
enall()
{
    local svcs
    IFS='-' read -r -a svcs <<< $(af_services)
    for svc in "${svcs[@]}"
    do
        enblt $1 $svc
    done
}
export -f enall


#==================================================================================================
dsall()
{
    local svcs
    IFS='-' read -r -a svcs <<< $(af_services)
    for svc in "${svcs[@]}"
    do
        dsblt $1 $svc
    done
}
export -f dsall


#==================================================================================================
adpath()
{
    echo $PATH
    export PATH="$1:$PATH"
    echo "==================================================="
    echo $PATH
}
export -f adpath

#==================================================================================================
gphelp()
{
    echo "ts commands"
    echo "rsallt:  restart/start all services"
    echo "         rsallt [az, os]"
    echo "stpallt: stop all services"
    echo "         stpallt [az, os]"
    echo "svc:     check service"
    echo "         svc [st, stp, rs, sts]"
    echo "svct:     check service"
    echo "         svc [af,os] [sch, web, log, srv, flw] [st, stp, rs, sts, en]"
    echo "afhome: set AIRFLOW_HOME"
    echo "         afhome [az, os]"
    echo "enblt: enable service"
    echo "       enblt [az, os] [sch, web, log, srv, flw]"
    echo "dsblt: disable service"
    echo "       dsblt [az, os] [sch, web, log, srv, flw]"
    echo "stall: start all services"
    echo "        dstall [az,os]"
    echo "spall: stop all services"
    echo "        entall [az,os]"
    echo "dstall: disable all services"
    echo "        dstall [az,os]"
    echo "entall: disable all services"
    echo "        entall [az,os]"
    echo "adpath: append to path"
    echo "        adpath <dir to add>"
    echo "---------------------------------------------------------------------------"
}

echo "Sourced airflow_exports.sh"
