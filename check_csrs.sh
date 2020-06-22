#!/bin/sh

# vim: ts=4 sw=4
# assumes you have either KUBECONFIG set of did oc login before as cluster admin

num_csrs="$( oc get csr -o name | wc -l )"
if [ "${num_csrs}" -gt 0 ]
then
    approved=$( oc get csr -o jsonpath="{.items[*].status.conditions[?(@.type=='Approved')].type}" | wc -w)
    test "${num_csrs}" = "1" && verb='is' || verb='are'
    if [ "${num_csrs}" -gt "${approved}" ]
    then
        echo "✘ There ${verb} ${num_csrs} CSR, ${approved} of them are already approved."
        exit 1
    else
        echo "✔ All CSRs are approved."
    fi
else
    echo "✔ There are no CSRs."
fi

