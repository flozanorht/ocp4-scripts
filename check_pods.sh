#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

pending=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Pending')].metadata.namespace}" )
#running=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Running')].metadata.namespace}" )
#succeeded=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Succeeded')].metadata.namespace}" )
failed=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Failed')].metadata.namespace}" )
unknown=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Unknown')].metadata.namespace}" )

if [ -n "${failed}" -o -n "${unknown}" -o -n "${pending}" ]
then
    if [ -n "${failed}" ]
    then
        echo '✘ Namespaces with failed pods:'
        echo "✘ $( echo ${failed} | sort | uniq )"
    else
        echo "✔ There are no failed pods."
    fi

    if [ -n "${unknown}" ]
    then
        echo '✘ Namespaces with pods in an unknown stage:'
        echo "✘ $( echo ${unknown} | sort | uniq )"
    else
        echo "✔ There are no pods in an unknown state."
    fi

    if [ -n "${pending}" ]
    then
        echo '✘ Namespaces with pending pods:'
        echo "✘ $( echo ${pending} | sort | uniq )"
    else
        echo "✔ There are no pending pods."
    fi

    exit 1
else
    echo "✔ All pods are either running or succeeded."
fi
