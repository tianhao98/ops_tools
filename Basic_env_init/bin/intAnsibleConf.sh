#!/bin/bash
cd $(dirname "$0") || exit
PWD=$(pwd)

config_file="${PWD}/../conf/basic.ini"
. "$config_file"
INIT_IPS=""
HOST_CONF="${PWD}/../ansible/hosts.ini"
HOST_TEMP="${PWD}/../ansible/hosts-temp.ini"

function build_conf(){
    cp "${HOST_TEMP}" "${HOST_CONF}"
}

function replace_vars(){
    local ip_list=(${ALLIP//,/ })
    for ip in "${ip_list[@]}";do 
        INIT_IPS+="${ip}\n"
    done
    sed -i 's/{init}/'${INIT_IPS}'/g' ${HOST_CONF}
    sed -i 's/{NTPD_HOST}/'${NTPD_HOST}'/g' ${HOST_CONF}
    sed -i 's/{NTPD_INSTALL}/'${NTPD_INSTALL}'/g' ${HOST_CONF}
}

build_conf
replace_vars
