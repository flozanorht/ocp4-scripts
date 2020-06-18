#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

cd $(dirname $0)

status=0

if ./check_api.sh
then
    ./check_nodes.sh
    status=$(( status || $? ))
    ./check_cos.sh
    status=$(( status || $? ))
    ./check_csrs.sh
    status=$(( status || $? ))
    exit $status
else
    exit 1
fi
