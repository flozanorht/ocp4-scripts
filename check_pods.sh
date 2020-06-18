#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

num_pods=$( oc get pod -A -o name | wc -l )
pending=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Pending')].metadata.name}" )
#running=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Running')].metadata.name}" )
#succeeded=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Succeeded')].metadata.name}" )
failed=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Failed')].metadata.name}" )
unknown=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Unknown')].metadata.name}" )

num_failed=$( echo "${failed}" | wc -w )
num_unknown=$( echo "${unknown}" | wc -w )
num_pending=$( echo "${pending}" | wc -w )

num_errors=$(( num_unknown + num_failed ))

if [ "${num_failed}" -gt 0 -o "${num_unknown}" -gt 0 ]
then
    echo "✘ There are ${num_pods} pods on the cluster, ${num_errors} of them are with either failed or unkown status, and ${num_pending} of them are pending."

    ns_failed=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Failed')].metadata.namespace}" )
    ns_unknown=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Unknown')].metadata.namespace}" )
    echo '✘ Namespaces with failed pods:'
    echo "✘ ${ns_failed}"
    echo '✘ Namespaces with pods in an unknown state:'
    echo "✘ ${ns_unknown}"

    exit 1
else
    echo "✔ There are ${num_pods} pods on the cluster, none of them are in error, ${num_pending} of them are pending."
fi
