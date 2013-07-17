#!/usr/bin/env bash
# SAVI Testbed login script
#
# 1. user name
# 2. tenant name
# 3. region name

if [[ -n "$1" ]]; then
    USER_NAME=$1
else
    ERR=1
fi

if [[ -n "$2" ]]; then
    PROJECT_NAME=$2
else
    ERR=1
fi

if [[ -n "$3" ]]; then
   REGION_NAME=$3
else
    ERR=1
fi

if [[ -z "$ERR" ]]; then
    read -s -p "Password: " savipw
    echo ""
    
    source openrc $1 $2 $3 iam.savitestbed.ca
    export OS_PASSWORD=$savipw

    echo "[$OS_USERNAME] is ready for [$OS_TENANT_NAME] on [$OS_REGION_NAME]."
else
    echo "Usage: savi.sh <user name> <project or tenant name> <region name>"
fi

