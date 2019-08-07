#!/bin/bash
cd `dirname $0`
PWD=`pwd`

CONFIG_FILE="${PWD}/../conf/basic.ini"
source $CONFIG_FILE

while getopts "h:c:m:" OPT 
do
    case ${OPT} in 
        h)
            ips=${OPTARG}
            ;;
        c)
            CONFIG_FILE=${OPTARG}
            ;;
        m)
            MODULE=${OPTARG}
            ;;
        ?)
            echo "use -h <hosts> for hosts or -c <config-file>  -m <module> for configuration"
            exit 1
            ;;
    esac
done

IPS=${ALLIP},${ips}
IPS=${IPS//,/ }
INVALID_OS_VERSION=(".*CentOS.*\s7\.[0-9]+.*" ".*Red\sHat.*\s7\.[0-9]+.*")

function info_log(){
    local content=$1
    echo -e "[\033[32m ${content} \033[0m]"
}

function error_log(){
    local content=$1
    echo -e "[\033[31m ${content} \033[0m]"
}

function  warning_log(){
    local content=$1
    echo -e "[\033[1;33m ${content} \033[0m]"
}

# 检查是否有expect，并安装
function check_expect(){
    EXPECT=`which expect`
    if [ ! -n $EXPECT ];then
        yun -y install expect >> /dev/null  2>&1
        info_log 'expect command install success'
    fi
}

# expect 免交互式
function sshExpect(){
    local user=$1
    local targetip=$2
    local password=$3
    /usr/bin/expect << EOF
        spawn ssh-copy-id -o "StrictHostKeyChecking no" $user@$targetip
        expect {
                "*password:" { send "$password\r"; exp_continue}
                eof { send_user "${targetip} ssh trnnel success\n"}
        }
EOF
}

# 所有主机建立互信
function OpenSshTunnel(){
    check_expect
    if [ ! -f ${USER}/.ssh/id_rsa ] || [ ! -f ${USER}/.ssh/id_rsa.pub ];then
        rm -rf ${USER}/.ssh/*
        ssh-keygen -q -P "" -f ${USER}/.ssh/id_rsa && cp ${USER}/.ssh/id_rsa.pub ${USER}/.ssh/authorized_keys
    fi
    for ip in ${IPS};do
        sshExpect ${USER} ${ip} ${PASSWD}
        [ $? -ne 0 ] && error_log "${ip} open tunnel failed" || info_log "${ip} open tunnel success"
    done
}

# 检查系统版本
function check_os() {
    for ip in ${IPS};do
        local release=`ssh ${USER}@$ip "cat /etc/redhat-release"`
        for version in ${INVALID_OS_VERSION[@]};do
            if [[ ${release} =~ ${version} ]];then
                local os_status=true
                break
            fi
        done

        if [ ${os_status} != true ];then
            error_log "Host ${ip} OS ${release}"
        else
            info_log "Host ${ip} OS ${release}"
        fi
    done
}

# function check_selinux(){
#     for ip in ${IPS};do
#         local selinux_conf_status=$(sh ${USER}@${ip} "awk  -F "=" '/^SELINUX=/ {print \$2}' /etc/selinux/config")
#         local selinux_status=$(sh ${USER}@${ip} "getenforce")
#         if [ ${selinux_conf_status} == 'disabled' ] || [ ${selinux_status} == 'Disabled' ];then
#             info_log "Host: ${ip} selinux status disabled"
#         else
#             sh ${USER}@${ip} "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && setenforce 0"
            
#         fi
#     done
    
# }

# function check_iptable(){

# }

# 检查分区是否为xfs
function check_xfs(){
    for ip in ${IPS};do
        local part_type=$(ssh ${USER}@${ip} "df -T /var/lib/docker/ | awk '/^\// {print \$2}'")
        if [ ${part_type} == 'xfs' ];then 
            error_log "Host: ${ip} /var/lib/docker partition system: xfs"
        else
            info_log "Host: ${ip} Partition type: ${part_type}"
        fi
    done
}

# 检查ntp
function check_ntp(){
    for ip in ${IPS};do
        local time=`ssh ${USER}@${ip} "date +%s"`
        local now=$(date +%s)
        let DIFF=time-now
        if [ ${DIFF} -le 2 ];then 
            info_log "Host: ${ip} ntp synchronized success, time stamp: "${now}""
        else
            error_log "Host: ${ip} ntp synchronized failed time stamp: "${now}""
        fi
    done
}

function display_title(){
       local title=$1
       echo -e "-----------------------"${title}"-----------------------"
}

# 执行模块
function exec_module(){
    if [ ! -n ${MODULE} ];then
	echo $MODULE
        error_log "The module name needs to be passed in -m <module>"
        exit 1
    fi
    display_title ${MODULE}
    eval ${MODULE}
}

exec_module
