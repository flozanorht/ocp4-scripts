#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

#num_pods=$( oc get pod -A -o name | wc -l )
pending=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Pending')].metadata.name}" )
#running=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Running')].metadata.name}" )
#succeeded=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Succeeded')].metadata.name}" )
failed=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Failed')].metadata.name}" )
unknown=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Unknown')].metadata.name}" )

num_failed=$( echo "${failed}" | wc -w )
num_unknown=$( echo "${unknown}" | wc -w )
num_pending=$( echo "${pending}" | wc -w )

num_errors=$(( num_unknown + num_failed ))

if [ "${num_errors}" -gt 0 ]
then
    # Need more for grammarly correct sentence
    test "${num_errors}" = "1" && verb='is' || verb='are'
    echo "✘ There ${verb} ${num_errors} failed or unkown status pods and also ${num_pending} pending pods."

    ns_failed=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Failed')].metadata.namespace}" )
    ns_unknown=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Unknown')].metadata.namespace}" )
    echo '✘ Namespaces with failed pods:'
    echo "✘ ${ns_failed}"
    echo '✘ Namespaces with pods in an unknown state:'
    echo "✘ ${ns_unknown}"

    exit 1
else
    if [ "${num_pending}" -gt 0 ]
    then
        # Need more for grammarly correct sentence
        test "${num_pending}" = "1" && verb='is' || verb='are'
        ns_pending=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Pending')].metadata.namespace}" )
        echo "✘ There ${verb} ${num_pending} pods pending in the following projects:"
        echo "✘ ${ns_pending}"
        exit 1
    else
        echo "✔ All pods are fine."
    fi
fi
