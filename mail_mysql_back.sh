#!/bin/bash

USER="backup"
PASSWORD="backupuser"
MYSQL_IP="192.168.65.112"
MYSQL_BACK_PATH="/home/Mysql_back"
MYSQL_BIN_PATH="/home/coremail/mysql/bin"
DATE=`date +%F`
MYSQL_BACK_NAME="mysql_back${DATE}.sql.gz"
LOG_FILE="${MYSQL_BACK_PATH}/Mysql_backup.log"

# -----------------------------------------------------------

while getopts "P:" opt; do
  case $opt in
    P)
     MYSQL_PORT="-P${OPTARG}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      ;;
  esac
done

INFO_log(){
    content=$1
    echo -e "`date`\033[32m [INFO] \033[0m ${content}" >> ${LOG_FILE}
}

WARNING_log(){
    content=$1
    echo -e "`date`\033[31m [WARNING] \033[0m ${content}" >> ${LOG_FILE}
}

Check_status(){
    status=$?
    if [ ${status} -eq 0 ]
    then
        INFO_log "exit status:${status}, ${MYSQL_BIN_PATH}/${MYSQL_BACK_NAME} is Succsee"
    else
        WARNING_log "exit status:${status}, ${MYSQL_BIN_PATH}/${MYSQL_BACK_NAME} is Fail"
    fi
}

Back_func(){
    if [ -d ${MYSQL_BACK_PATH} -a  ! -f ${MYSQL_BACK_PATH}/${MYSQL_BACK_NAME} ]
    then
        ${MYSQL_BIN_PATH}/mysqldump -u${USER} -p${PASSWORD} ${MYSQL_PORT} -h${MYSQL_IP} --default-character-set=utf8 --skip-lock-tables -A | gzip >  ${MYSQL_BACK_PATH}/${MYSQL_BACK_NAME}
        Check_status
    else
        WARNING_log "check ${MYSQL_BACK_PATH} and ${MYSQL_BACK_PATH}/${MYSQL_BACK_NAME}"
    fi
}

Back_clean(){
    find ${MYSQL_BACK_PATH} -maxdepth 1  -name 'mysql_back*.sql.gz' -type f -mtime +7 > ${MYSQL_BACK_PATH}/file_list.txt
    for file in  `cat ${MYSQL_BACK_PATH}/file_list.txt`
    do
        if [ -f ${file} ]
        then
            rm -rf ${file}
            
            INFO_log "${MYSQL_BACK_PATH}/${file} Delete is Succsee"
        else
            WARNING_log "${MYSQL_BACK_PATH}/${file} file is not fount"
        fi
    done
}

Back_func
Back_clean
