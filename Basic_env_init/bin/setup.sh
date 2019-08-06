#!/bin/bash

cd `dirname $0`
PWD=`pwd`
config_file="${PWD}/../conf/basic.ini"
source config_file
sh ${PWD}/intAnsibleConf.sh

while gatopts "dc:" OPT;do
    case ${OPT} in 
        d)
            DEBUG='-x'
            ;;
        c)
            config_file=${OPTARG}
            ;;
        ?)
            echo "Unknown argument, use -d for debug or -c <config-file> for configuration"
            exit 1
            ;;
    esac
done

if [ ! -f ${config_file} ];then
    echo "The configuration file does not exist "
    exit 1
fi

# 选项说明
function display(){
    echo -e "\033[32m\
\n-----------------------------------------\n\
\t\t基础环境检查配\n\
1. 建立互信\n\
2. 检查分区是否为xfs\n\
3. 检查所有主机os系统\n\
4. 安装ntp\n\
5. 检查时间是否同步\n\
6. 部署镜像中心\n\
7. 批量安装jp包\n\
8. 部署helm\n\
\033[0m"
}

while true;do
    display
    read -p "请根据编号选择要部署的任务输入q可以退出：" NUM
    case ${NUM} in
    "1")
        /usr/bin/sh ${debug} CheckEnv.sh ${config_file} "OpenSshTunnel"
        ;;
    "2")
        /usr/bin/sh ${debug} CheckEnv.sh ${config_file} "check_xfs"
        ;;
    "3")
        /usr/bin/sh ${debug} CheckEnv.sh ${config_file} "check_os"
        ;;
    "4")
        /usr/bin/sh ${debug} CheckEnv.sh ${config_file} "check_ntp"
done