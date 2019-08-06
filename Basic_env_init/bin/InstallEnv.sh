#!/bin/bash
cd $(dirname "$0") || exit
PWD=$(pwd)

CONFIG_FILE="${PWD}/../conf/basic.ini"
. $CONFIG_FILE
