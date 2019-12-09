#!/bin/bash

# 用于A，B机房MySQL进行切换域名
# A为主机房，B为备机房（B机房mysql用于在A机房mysql down后顶替使用，A机房恢复健康db域名会自切换到A机房MySQL）
# 脚本用于在B机房执行，不断检查A机房MySQL是否健康，不健康会触发dns域名切换到B机房MySQL，A机房恢复健康后，B机房检测到后会主动把dns记录切换到A机房

CHECK_TIME=1
CHECK_NIMBER=3
SUFFIX='x'
MASTER_DATACENTER_DNS='192.168.1.3'
SLAVE_DATACENTER_DNS='192.168.1.23'
DNS_RECORDS='dbhost.test.com'
SLAVE_IP='192.168.1.150'
MASTER_IP='192.168.1.135'

# 指定mysql连接参数
while getopts ":h:u:p:t" opt;do
    case ${opt} in
        h)
            HOST=${OPTARG}
        ;;
        u)
            USER=${OPTARG}
        ;;
        p)
            PASSWD=${OPTARG}
        ;;
        t)
            # 用于脚本测试
            TEST='echo -e'
        ;;
    esac
done

# 输出log函数
function log_format(){
    time=$(date +"%Y-%m-%d-%T")
    level=$1
    content=$2
    echo -e "${time} ${level} ${content}"
}

# 检查
function check_mysql_health(){
    local status=$(mysqladmin -u${USER} -h${HOST} -p${PASSWD} ping --connect-timeout=1 | sed -r 's/.*(alive)/\1/g')  

    if [ ${status}x == 'alivex' ];then
        log_format "IFNO" "Check mysql state for alive"
        return 0
    else
        log_format "WARNING" "Check mysql state for down"
        return 1
    fi
}

# 切换mysql域名解析地址
function switch_dns_slave(){

    # 在两个机房移除 原mysql dns记录
    ${TEST} curl --connect-timeout 2 "http://${MASTER_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=remove&name=${DNS_RECORDS}&ip=${MASTER_IP}"
    ${TEST} curl --connect-timeout 2  "http://${SLAVE_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=remove&name=${DNS_RECORDS}&ip=${MASTER_IP}"
    log_format "IFNO" "Remove the original DNS record"

    # 在两个机房添加切换mysql dns记录
    ${TEST} curl --connect-timeout 2 "http://${MASTER_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=add&name=${DNS_RECORDS}&ip=${SLAVE_IP}"
    ${TEST} curl --connect-timeout 2 "http://${SLAVE_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=add&name=${DNS_RECORDS}&ip=${SLAVE_IP}"
    log_format "IFNO" "Start switching mysql DNS records"
}

function switch_dns_master(){

    # 在两个机房移除 原mysql dns记录
    ${TEST} curl --connect-timeout 2 "http://${MASTER_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=remove&name=${DNS_RECORDS}&ip=${SLAVE_IP}"
    ${TEST} curl --connect-timeout 2  "http://${SLAVE_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=remove&name=${DNS_RECORDS}&ip=${SLAVE_IP}"
    log_format "IFNO" "Remove the original DNS record"

    # 在两个机房添加切换mysql dns记录
    ${TEST} curl --connect-timeout 2 "http://${MASTER_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=add&name=${DNS_RECORDS}&ip=${MASTER_IP}"
    ${TEST} curl --connect-timeout 2 "http://${SLAVE_DATACENTER_DNS}:80/cgi-bin/dnsapi.cgi?action=add&name=${DNS_RECORDS}&ip=${MASTER_IP}"
    log_format "IFNO" "DNS record switched to mysql master address"
}

# 执行函数
function main(){
    local master_dns_records_ip=$(nslookup -timeout=2 ${DNS_RECORDS} ${MASTER_DATACENTER_DNS} | grep -v 53 | grep Address | sed -r 's/Address\: ([1-9]+\.[1-9]+\.[1-9]+\.[1-9]+)/\1/g')
    local slave_dns_records_ip=$(nslookup -timeout=2 ${DNS_RECORDS} ${SLAVE_DATACENTER_DNS} | grep -v 53 | grep Address | sed -r 's/Address\: ([1-9]+\.[1-9]+\.[1-9]+\.[1-9]+)/\1/g')
    check_mysql_health
    if [ 0 -eq $? ];then
        if [[ ${MASTER_IP}x != ${master_dns_records_ip}x || ${MASTER_IP}x != ${slave_dns_records_ip}x ]];then
            switch_dns_master
            retrun 0
        else
            log_format "IFNO" "master datacenter dns records: ${}"
        fi
    fi

    local error=0
    for ((i=1;i<=${CHECK_NIMBER};i++));do
        check_mysql_health
        if [ $? -ne 0 ];then
            let error++
        fi
        sleep $CHECK_TIME
    done

    if [ ${error} -eq 3 ];then
        # 假如主机房dns已经down机器（timeout），备机房dns记录不为备mysql地址则切换dns记录到备机房mysql
        # 假如主机房dns解析正常，主备机房dns解析地址不为备mysql地址则切换dns记录到备机房mysql
        local other_dns_records_result=$(nslookup ${DNS_RECORDS} ${OTHER_DATACENTER_DNS} |grep time| sed -r 's/.*(timed out).*/\1/g' | sed 's/ //g')
        if [ ${other_dns_records_result}x == 'timedoutx' ];then
            if [ ${slave_dns_records_ip}x != ${SLAVE_IP}x ];then
                switch_dns_slave
            fi
        elif [[ ${master_dns_records_ip} != ${SLAVE_IP}x || ${slave_dns_records_ip} != ${SLAVE_IP}x ]];then
            switch_dns_slave
        fi
    else
        log_format "WARNING" "The number of test failures in three seconds is ${error},No DNS switch DNS records"
    fi
}

while true;do
    main
    sleep 3
done