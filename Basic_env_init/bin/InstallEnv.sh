#!/bin/bash
cd $(dirname "$0") || exit
PWD=$(pwd)

ANSIBLE_HOST="${PWD}/../ansible/hosts.ini"
ANSIBLE_SITE="${PWD}/../ansible/site.yaml"
CONFIG_FILE="${PWD}/../conf/basic.ini"
. $CONFIG_FILE


while getopts "c:m:d" OPT;do 
     case "${OPT}" in 
       "c")
 	  CONFIG_FILE=${OPTARG}
          ;;
       "m")
         MODULE=${OPTARG}
         ;;
       "b")
         DEBUG='-v'
         ;;
       "?")
          echo "use -c <config-file>  -m <module> for configuration" 
          exit 1
          ;;
     esac
done

function exec_ansible(){
  ansible-playbook "${DEBUG}" -i "${ANSIBLE_HOST}" -e project="${MODULE}" "${ANSIBLE_SITE}"
}

exec_ansible