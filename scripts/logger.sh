#!/bin/bash

# purpose: to pass msgs and print them to a log file and terminal
#  - with datetime
#  - the type of msg - INFO, ERROR, DEBUG, WARNING
# usage:
# do_log "INFO some info message"
# do_log "ERROR some error message"
# do_log "DEBUG some debug message"
# do_log "WARNING some warning message"
# depts:
#  - PRODUCT_DIR - the root dir of the sfw project
#  - PRODUCT - the name of the software project dir
#  - host_name - the short hostname of the host / container running on
# 
# from : Yordan Georgiev (stackoverflow)
#------------------------------------------------------------------------------
source /etc/czillapxe/czillapxe.cfg

do_log(){
    print_ok() {
        GREEN_COLOR="\033[0;32m"
        DEFAULT="\033[0m"
        echo -e "${GREEN_COLOR} ✔ [OK] ${1:-} ${DEFAULT}"
    }

    print_warning() {
        YELLOW_COLOR="\033[33m"
        DEFAULT="\033[0m"
        echo -e "${YELLOW_COLOR} ⚠ ${1:-} ${DEFAULT}"
    }

    print_info() {
        BLUE_COLOR="\033[0;34m"
        DEFAULT="\033[0m"
        echo -e "${BLUE_COLOR} ℹ ${1:-} ${DEFAULT}"
    }

    print_fail() {
        RED_COLOR="\033[0;31m"
        DEFAULT="\033[0m"
        echo -e "${RED_COLOR} ❌ [NOK] ${1:-}${DEFAULT}"
    }

    type_of_msg=$(echo $*|cut -d" " -f1)
    msg="$(echo $*|cut -d" " -f2-)"
    log_file="$czillaCOnfigDir/czillapxe.log"
    msg=" [$type_of_msg] `date "+%Y-%m-%d %H:%M:%S %Z"` [${PRODUCT:-}][@${host_name:-}] [$$] $msg "
    case "$type_of_msg" in
        'FATAL') print_fail "$msg" | tee -a $log_file ;;
        'ERROR') print_fail "$msg" | tee -a $log_file ;;
        'WARNING') print_warning "$msg" | tee -a $log_file ;;
        'INFO') print_info "$msg" | tee -a $log_file ;;
        'OK') print_ok "$msg" | tee -a $log_file ;;
        *) echo "$msg" | tee -a $log_file ;;
    esac
}