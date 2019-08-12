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

    local docker_list=(${DOCKER_HOST//,/ })
    for ip in "${docker_list[@]}";do 
        DOCKER_IPS+="${ip}\n"
    done

    sed -i 's/{init}/'${INIT_IPS}'/g' ${HOST_CONF}
    sed -i 's/{NTPD_HOST}/'${NTPD_HOST}'/g' ${HOST_CONF}
    sed -i 's/{DOCKER_REGISTRY}/'${DOCKER_REGISTRY}'/g' ${HOST_CONF}
    sed -i 's/{docker}/'${DOCKER_IPS}'/g' ${HOST_CONF} 
    sed -i 's/{harbor}/'${BARBOR_HOST}'/g' ${HOST_CONF}
    sed -i 's/{BARBOR_PASSWD}/'${BARBOR_PASSWD}'/g' ${HOST_CONF}
    sed -i 's#{BARBOR_STORAGE}#'${BARBOR_STORAGE}'#g' ${HOST_CONF}
    sed -i 's/{HELM_HOST}/'${HELM_HOST}'/g' ${HOST_CONF}
    sed -i 's/{KUBE_MASTER}/'${KUBE_MASTER}'/g' ${HOST_CONF}
    sed -i 's/{TILLER_NODE}/'${TILLER_NODE}'/g' ${HOST_CONF}
} 

build_conf
replace_vars