#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

cd $(dirname $0)
./check_nodes.sh
./check_cos.sh
